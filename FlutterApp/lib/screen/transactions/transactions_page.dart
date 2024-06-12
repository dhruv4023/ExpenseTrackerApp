import 'dart:convert';
import 'package:expense_tracker/functions/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/Models/Transactions.dart';
import 'package:expense_tracker/Models/LabelMetaData.dart';
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart
import 'package:expense_tracker/functions/switches.dart';
import 'package:expense_tracker/widgets/bottom_nav_bar.dart'; // Import BottomNavBar
import 'package:expense_tracker/widgets/custom_app_bar.dart';
import 'package:expense_tracker/functions/auth_shared_preference.dart';
import 'package:expense_tracker/functions/drop_ctrl.dart';
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
    fetchTransactions();
    super.initState();
  }

  Future<void> fetchTransactions({int page = 1}) async {
    String? walletId = await retriveWalletId();

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
        '$API_URL/transaction/get/wallet/$walletId?page=$page&limit=10');
    final headers = {'Authorization': await retriveToken()};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data == null ||
            data["data"] == null ||
            data["data"]["transactions"] == null) {
          throw Exception('Invalid data format');
        }

        final transactionsData = data["data"]["transactions"];
        final List<dynamic>? transactionsJson = transactionsData["page_data"];
        final List<dynamic>? labelsJson = transactionsData["labels"];

        if (transactionsJson == null) {
          throw Exception('transactionsJson is null');
        }

        if (labelsJson == null) {
          throw Exception('labelsJson is null');
        }

        setState(() {
          labelsMetadata = labelsJson
              .map<LabelMetaData>((json) => LabelMetaData.fromJson(json))
              .toList();

          transactions = transactionsJson
              .map<Transaction>((json) => Transaction.fromJson(json))
              .toList();

          currentPage =
              transactionsData["page_information"]?["current_page"] ?? 1;
          totalPages = transactionsData["page_information"]?["last_page"] ?? 1;
          metadata = transactionsData["page_information"] ?? {};
          isLoading = false;
        });
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(
            'Failed to load transactions: ${errorResponse['message']}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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

  Future<void> _addTransaction() async {
    final commentController = TextEditingController();
    final amountController = TextEditingController();
    final List<String> selectedLabelIds = [];
    final DropContr dropDrCrContr = DropContr("-");

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: commentController,
                decoration: const InputDecoration(hintText: "Enter comment"),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(hintText: "Enter amount"),
                keyboardType: TextInputType.number,
              ),
              // Dropdown for debit/credit selection
              Consumer<DropContr>(
                builder: (context, dropDrCrContr, child) {
                  return DropdownButton<String>(
                    value: dropDrCrContr.selectedValue,
                    items: const [
                      DropdownMenuItem(
                        value: "-",
                        child: Text("Debit"),
                      ),
                      DropdownMenuItem(
                        value: "+",
                        child: Text("Credit"),
                      )
                    ],
                    onChanged: (String? newValue) {
                      dropDrCrContr.selectedValue = newValue;
                    },
                  );
                },
              ),
              // Dropdown for selecting multiple labels
              Consumer<DropContr>(
                builder: (context, dropContr, child) {
                  return DropdownButton<String>(
                    isExpanded: true,
                    value:
                        null, // Since multiple selection is allowed, initially no value is selected
                    hint: Text('Select label(s)'),
                    items: labelsMetadata
                        .map((e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.labelName),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      // Toggle selection
                      if (selectedLabelIds.contains(newValue!)) {
                        selectedLabelIds.remove(newValue);
                      } else {
                        selectedLabelIds.add(newValue);
                      }
                    },
                    // Allow multiple selection
                    // Use a different method to handle selection changes
                    // Since DropdownButton doesn't support multiple selections out of the box
                    selectedItemBuilder: (BuildContext context) {
                      return selectedLabelIds.map<Widget>((String value) {
                        final label = labelsMetadata
                            .firstWhere((element) => element.id == value);
                        return Chip(
                          label: Text(label.labelName),
                          onDeleted: () {
                            setState(() {
                              selectedLabelIds.remove(value);
                            });
                          },
                        );
                      }).toList();
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null) {
                    showToast('Invalid amount');
                    return;
                  }
                  if (selectedLabelIds.isEmpty) {
                    showToast('No label selected');
                    return;
                  }
                  await TransactionService.addTransaction(
                    commentController.text,
                    double.parse(
                        dropDrCrContr.selectedValue! + amountController.text),
                    selectedLabelIds,
                  );
                  await fetchTransactions();
                  Navigator.of(context).pop();
                } catch (e) {
                  showToast(e.toString());
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editTransactionComment(String walletId) async {
    final newCommentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Transaction Comment'),
          content: TextField(
            controller: newCommentController,
            decoration: InputDecoration(hintText: "Enter new comment"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await TransactionService.editTransactionComment(
                      walletId, newCommentController.text);
                  await fetchTransactions();
                  Navigator.of(context).pop();
                } catch (e) {
                  showToast(e.toString());
                }
              },
              child: Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editTransactionLabels(String transactionId) async {
    List<String> selectedLabelIds = []; // List to store selected label IDs

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Transaction Labels'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: null, // Initially no value is selected
                    hint: Text('Select new label(s)'),
                    items: labelsMetadata
                        .map((e) => DropdownMenuItem(
                              child: Text(e.labelName),
                              value: e.id,
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      // Toggle selection
                      if (selectedLabelIds.contains(newValue!)) {
                        selectedLabelIds.remove(newValue);
                      } else {
                        selectedLabelIds.add(newValue);
                      }
                      setState(
                          () {}); // Update the dialog to reflect the selection change
                    },
                    // Allow multiple selection
                    selectedItemBuilder: (BuildContext context) {
                      return selectedLabelIds.map<Widget>((String value) {
                        final label = labelsMetadata
                            .firstWhere((element) => element.id == value);
                        return Chip(
                          label: Text(label.labelName),
                          onDeleted: () {
                            setState(() {
                              selectedLabelIds.remove(value);
                            });
                          },
                        );
                      }).toList();
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await TransactionService.editTransactionLabels(
                      transactionId, selectedLabelIds);
                  await fetchTransactions();
                  Navigator.of(context).pop();
                } catch (e) {
                  showToast(e.toString());
                }
              },
              child: Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTransaction(String walletId) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Transaction'),
          content: Text('Are you sure you want to delete this transaction?'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await TransactionService.deleteTransaction(walletId);
                  await fetchTransactions();
                  Navigator.of(context).pop();
                } catch (e) {
                  showToast(e.toString());
                }
              },
              child: Text('Delete'),
            ),
          ],
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
              // : transactions.isEmpty
              //     ? const Text("No transaction found")
              : Expanded(
                  child: TnxWidget(
                    transactions: transactions,
                    labelsMetadata: labelsMetadata,
                    onEditTransactionComment: _editTransactionComment,
                    onEditTransactionLabel: _editTransactionLabels,
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
