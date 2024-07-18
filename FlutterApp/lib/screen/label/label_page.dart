// lib/screens/labels_page.dart

import 'dart:convert';
import 'package:expense_tracker/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/Models/Label.dart';
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart
import 'package:expense_tracker/widgets/base_scaffold.dart';
import 'package:expense_tracker/functions/auth_shared_preference.dart';
import 'package:expense_tracker/screen/label/widgets/label_list.dart';
import 'package:expense_tracker/services/label_service.dart';
import 'package:expense_tracker/functions/show_toast.dart';
import 'package:expense_tracker/Models/Account.dart';
import 'package:expense_tracker/services/account_service.dart';

class LabelsPage extends StatefulWidget {
  const LabelsPage({Key? key}) : super(key: key);

  @override
  _LabelsPageState createState() => _LabelsPageState();
}

class _LabelsPageState extends State<LabelsPage> {
  List<Label> labels = [];
  bool isLoading = true;
  List<Account> accounts = [];

  @override
  void initState() {
    super.initState();
    fetchLabelsAccountsAndBalance();
  }

  Future<void> fetchLabelsAccountsAndBalance() async {
    try {
      String? walletId = await retriveWalletId();
      if (walletId == null) Navigator.of(context).pushReplacementNamed('/home');

      setState(() {
        isLoading = true; // Start loading indicator
      });
      final url = '$API_URL/label_account/get/wallet/${walletId}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': await retriveToken(),
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data);
        setState(() {
          labels = (data['data']["labelsAccounts"]['labels'] as List)
              .map((item) => Label.fromJson(item))
              .toList();
          accounts = (data['data']["labelsAccounts"]['accounts'] as List)
              .map((item) => Account.fromJson(item))
              .toList();
          isLoading = false; // Stop loading indicator
        });
      } else {
        throw Exception('Failed to load labels: ${response.statusCode}');
      }
    } catch (e) {
      showToast('Error fetching labels: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop loading indicator
      });
    }
  }

  Future<void> _setDefaultLabel(String id, bool isAccount) async {
    try {
      setState(() {
        isLoading = true; // Start loading indicator
      });
      isAccount
          ? await AccountService.setDefaultAccount(id)
          : await LabelService.setDefaultLabel(id);
      await fetchLabelsAccountsAndBalance();
    } catch (e) {
      showToast(e.toString());
    } finally {
      setState(() {
        isLoading = false; // Stop loading indicator
      });
    }
  }

  Future<void> _addLabel() async {
    final nameController = TextEditingController();
    bool isAccount = false;
    final openingBalanceController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        bool _isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> handleAdd() async {
              setState(() {
                _isLoading = true;
              });

              try {
                final labelName = nameController.text.trim();
                if (labelName.isEmpty) {
                  showToast("Label name cannot be empty");
                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }
                if (isAccount) {
                  double? openingBalance =
                      double.tryParse(openingBalanceController.text) ?? 0.0;
                  await AccountService.addAccount(labelName, openingBalance);
                } else
                  await LabelService.addLabel(labelName);

                await fetchLabelsAccountsAndBalance();
                Navigator.of(context).pop();
              } catch (e) {
                showToast(e.toString());
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Add New Label / Account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading) CircularProgressIndicator(),
                  if (!_isLoading) ...[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "Enter label/account name",
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: const Color.fromARGB(255, 5, 5, 4),
                          value: isAccount,
                          onChanged: (bool? newValue) {
                            setState(() {
                              isAccount = newValue ?? false;
                            });
                          },
                        ),
                        const Text('Is Account'),
                      ],
                    ),
                    if (isAccount)
                      TextField(
                        controller: openingBalanceController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: "Enter opening balance",
                        ),
                      ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : handleAdd,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editLabelName(String id, bool isAccount) async {
    final newLabelOrAccountNameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        bool _isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> handleEdit() async {
              setState(() {
                _isLoading = true;
              });

              try {
                isAccount
                    ? await AccountService.editAccountName(
                        id, newLabelOrAccountNameController.text)
                    : await LabelService.editLabelName(
                        id, newLabelOrAccountNameController.text);

                await fetchLabelsAccountsAndBalance();
                Navigator.of(context).pop();
              } catch (e) {
                showToast("error: " + e.toString());
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            }

            return AlertDialog(
              title:
                  Text('Edit ' + (isAccount ? 'Account' : 'Label') + ' Name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading) CircularProgressIndicator(),
                  if (!_isLoading)
                    TextField(
                      controller: newLabelOrAccountNameController,
                      decoration: InputDecoration(
                          hintText: 'Enter new ' +
                              (isAccount ? 'Account' : 'Label') +
                              ' Name'),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : handleEdit,
                  child: const Text('Edit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteLabel(String Id, bool isAccount) async {
    try {
      setState(() {
        isLoading = true; // Start loading indicator
      });
      // final headers = {
      //   'Authorization': await retriveToken(),
      //   'Content-Type': 'application/json; charset=UTF-8',
      // };

      // final url =
      //     '$API_URL/label/delete/wallet/${await retriveWalletId()}/label/$Id';

      // final response = await http.delete(Uri.parse(url), headers: headers);

      // if (response.statusCode == 200) {
      //   await fetchLabelsAccountsAndBalance();
      //   showToast('Label deleted successfully');
      // } else {
      //   Map<String, dynamic> responseData = jsonDecode(response.body);
      //   throw Exception('${responseData["error"]}');
      // }
      showToast('NOT IMPLEMENTED');
    } catch (e) {
      showToast('Error deleting label: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        widgetIndex: 2,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: LabelList(
                  labels: labels,
                  accounts: accounts,
                  onEditLabelName: _editLabelName,
                  onSetDefaultLabel: _setDefaultLabel,
                  onDeleteLabel: _deleteLabel,
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addLabel,
          backgroundColor: tdBlue,
          elevation: 2, // Increase elevation for a raised effect
          tooltip: 'Add Label', // Optional tooltip
          child: Icon(
            Icons.add,
            size: 24, // Adjust icon size as needed
            color: tdBGColor, // Icon color
          ),
        ));
  }
}
