import 'dart:convert';
import 'package:expense_tracker/functions/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/Models/Transactions.dart';
import 'package:expense_tracker/Models/LabelMetaData.dart';
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart
import 'package:expense_tracker/functions/switches.dart';
import 'package:expense_tracker/widgets/bottom_nav_bar.dart'; // Import BottomNavBar
import 'package:expense_tracker/widgets/custom_app_bar.dart';
import 'package:expense_tracker/functions/auth_shared_preference.dart';
import 'package:expense_tracker/functions/drop_down_button.dart';
import 'package:expense_tracker/screen/transactions/widgets/tnxs_widget.dart';
import 'package:expense_tracker/widgets/pagination.dart';
import 'package:expense_tracker/services/transaction_service.dart'; // Import TransactionService

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  int _selectedIndex = 2;
  List<Transaction> transactions = [];
  List<LabelMetaData> labelsMetadata = [];
  bool isLoading = false;
  int currentPage = 1;
  int totalPages = 1;
  Map<String, dynamic>? metadata;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switches(index, context);
  }

  void setPage(page) {
    currentPage = page;
    fetchTransactions(page: currentPage);
  }

  Future<void> fetchTransactions({int page = 1}) async {
    String? walletId = await retriveWalletId();
    // print(await retriveToken());
    // print(await retriveWalletId());
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
        '$API_URL/transaction/get/wallet/$walletId?page=$page&limit=10');
    final headers = {
      'Authorization': await retriveToken(),
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> transactionsJson =
            data["data"]['transactions']["page_data"];

        final List<dynamic>? labelsJson =
            data["data"]["transactions"]['labels'];

        setState(() {
          if (labelsJson != null) {
            labelsMetadata =
                labelsJson.map((json) => LabelMetaData.fromJson(json)).toList();
          }
          transactions = transactionsJson
              .map((json) => Transaction.fromJson(json))
              .toList();
          currentPage =
              data["data"]['transactions']["page_information"]["current_page"];
          totalPages =
              data["data"]['transactions']["page_information"]["last_page"];
          metadata = data["data"]['transactions']["page_information"];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showToast('Error: $e');
      print('Error: $e');
    }
  }

  Future<void> _addTransaction() async {
    final commentController = TextEditingController();
    final amountController = TextEditingController();
    final DropController dropLabelContr = DropController(
        labelsMetadata.firstWhere((e) => e.isDefault && !e.isAccount).id);
    final DropController dropAccountContr = DropController(
        labelsMetadata.firstWhere((e) => e.isDefault && e.isAccount).id);
    final DropController dropDrCrContr = DropController("-");

    await showDialog(
      context: context,
      builder: (context) {
        bool isLoadingInsideDialog = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> handleAdd() async {
              setState(() {
                isLoadingInsideDialog = true;
              });

              try {
                final amount = double.tryParse(amountController.text);
                if (amount == null) {
                  showToast('Invalid amount');
                  setState(() {
                    isLoadingInsideDialog = false;
                  });
                  return;
                }
                if (dropAccountContr.selectedValue == null) {
                  showToast('No Account selected');
                  setState(() {
                    isLoadingInsideDialog = false;
                  });
                  return;
                }
                if (dropLabelContr.selectedValue == null) {
                  showToast('No label selected');
                  setState(() {
                    isLoadingInsideDialog = false;
                  });
                  return;
                }
                await TransactionService.addTransaction(
                  commentController.text,
                  double.parse(
                      dropDrCrContr.selectedValue! + amountController.text),
                  dropAccountContr.selectedValue!,
                  dropLabelContr.selectedValue!,
                );
                await fetchTransactions();
                Navigator.of(context).pop();
              } catch (e) {
                showToast(e.toString());
                setState(() {
                  isLoadingInsideDialog = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Add New Transaction'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoadingInsideDialog) CircularProgressIndicator(),
                  if (!isLoadingInsideDialog) ...[
                    TextField(
                      controller: commentController,
                      decoration:
                          const InputDecoration(hintText: "Enter comment"),
                    ),
                    TextField(
                      controller: amountController,
                      decoration:
                          const InputDecoration(hintText: "Enter amount"),
                      keyboardType: TextInputType.number,
                    ),
                    Row(
                      children: [
                        Text("Debit(-) or Credit(+) :"),
                        dropDownMenu(
                            dropDrCrContr, {"+": "Credit", "-": "Debit"})
                      ],
                    ),
                    Row(
                      children: [
                        Text("Select Account :"),
                        dropDownMenu(dropAccountContr, {
                          for (var label in labelsMetadata)
                            if (label.isAccount) label.id: label.labelName
                        }),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Select Label :"),
                        dropDownMenu(dropLabelContr, {
                          for (var label in labelsMetadata)
                            if (!label.isAccount) label.id: label.labelName
                        }),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoadingInsideDialog ? null : handleAdd,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editTransactionLabel(String transactionId) async {
    final DropController dropContr = DropController(
        labelsMetadata.firstWhere((e) => e.isDefault && !e.isAccount).id);

    bool isLoadingInsideDialog = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> handleEdit() async {
              setState(() {
                isLoadingInsideDialog = true;
              });

              try {
                await TransactionService.editTransactionLabel(
                    transactionId, dropContr.selectedValue ?? '');
                await fetchTransactions();
                Navigator.of(context).pop();
              } catch (e) {
                showToast(e.toString());
              } finally {
                setState(() {
                  isLoadingInsideDialog = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Edit Transaction Label'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoadingInsideDialog) CircularProgressIndicator(),
                  if (!isLoadingInsideDialog)
                    Row(
                      children: [
                        Text("Select Label :"),
                        dropDownMenu(dropContr, {
                          for (var label in labelsMetadata)
                            if (!label.isAccount) label.id: label.labelName
                        }),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoadingInsideDialog ? null : handleEdit,
                  child: const Text('Edit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editTransactionComment(String walletId) async {
    final newCommentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        bool isLoadingInsideDialog = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> handleEdit() async {
              setState(() {
                isLoadingInsideDialog = true;
              });

              try {
                await TransactionService.editTransactionComment(
                    walletId, newCommentController.text);
                await fetchTransactions();
                Navigator.of(context).pop();
              } catch (e) {
                showToast(e.toString());
              } finally {
                setState(() {
                  isLoadingInsideDialog = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Edit Transaction Comment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoadingInsideDialog) CircularProgressIndicator(),
                  if (!isLoadingInsideDialog)
                    TextField(
                      controller: newCommentController,
                      decoration:
                          const InputDecoration(hintText: "Enter new comment"),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoadingInsideDialog ? null : handleEdit,
                  child: const Text('Edit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteTransaction(String walletId) async {
    await showDialog(
      context: context,
      builder: (context) {
        bool isLoadingInsideDialog = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> handleDelete() async {
              setState(() {
                isLoadingInsideDialog = true;
              });

              try {
                await TransactionService.deleteTransaction(walletId);
                await fetchTransactions();
                Navigator.of(context).pop();
              } catch (e) {
                showToast(e.toString());
              } finally {
                setState(() {
                  isLoadingInsideDialog = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Delete Transaction'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoadingInsideDialog) CircularProgressIndicator(),
                  if (!isLoadingInsideDialog)
                    Text('Are you sure you want to delete this transaction?'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoadingInsideDialog ? null : handleDelete,
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isAuthenticated: true),
      body: Column(
        children: [
          if (metadata != null)
            Pagination(
              metadata: metadata as Map<String, dynamic>,
              setPage: setPage,
              page: currentPage,
            ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : transactions.isEmpty
                  ? const Text("No transaction found")
                  : Expanded(
                      child: TnxWidget(
                        transactions: transactions,
                        labelsMetadata: labelsMetadata,
                        onEditTransactionComment: _editTransactionComment,
                        onEditTransactionLabel: _editTransactionLabel,
                        onDeleteTransaction: _deleteTransaction,
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
