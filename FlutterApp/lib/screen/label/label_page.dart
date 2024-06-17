// lib/screens/labels_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/Models/Label.dart';
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart
import 'package:expense_tracker/functions/switches.dart';
import 'package:expense_tracker/widgets/bottom_nav_bar.dart'; // Import BottomNavBar
import 'package:expense_tracker/widgets/custom_app_bar.dart';
import 'package:expense_tracker/functions/auth_shared_preference.dart';
import 'package:expense_tracker/screen/label/widgets/label_list.dart';
import 'package:expense_tracker/services/label_service.dart';
import 'package:expense_tracker/functions/show_toast.dart';

class LabelsPage extends StatefulWidget {
  const LabelsPage({Key? key}) : super(key: key);

  @override
  _LabelsPageState createState() => _LabelsPageState();
}

class _LabelsPageState extends State<LabelsPage> {
  bool isAuthenticated = true;
  int _selectedIndex = 3;
  List<Label> labels = [];
  bool isLoading = true;
  int? _expandedIndex;
  int? _subExpandedIndex;
  @override
  void initState() {
    super.initState();
    fetchLabels();
  }

  Future<void> fetchLabels() async {
    try {
      setState(() {
        isLoading = true; // Start loading indicator
      });
      final url = '$API_URL/label/get/wallet/${await retriveWalletId()}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': await retriveToken(),
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          labels = (data['data']['labels'] as List)
              .map((item) => Label.fromMap(item))
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switches(index, context);
  }

  void _onExpansionChanged(int index, {bool subExpansion = false}) {
    if (subExpansion) {
      setState(() {
        _subExpandedIndex = index == _subExpandedIndex ? null : index;
      });
    } else {
      setState(() {
        _expandedIndex = index == _expandedIndex ? null : index;
      });
    }
  }

  Future<void> _addLabel() async {
    final labelNameController = TextEditingController();
    bool isAccount = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Label / Account'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelNameController,
                    decoration: InputDecoration(
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
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  setState(() {
                    isLoading = true; // Start loading indicator
                  });
                  final labelName = labelNameController.text.trim();
                  if (labelName.isEmpty) {
                    showToast("Label name cannot be empty");
                    return;
                  }
                  await LabelService.addLabel(labelName, isAccount);
                  await fetchLabels();
                  Navigator.of(context).pop();
                } catch (e) {
                  showToast(e.toString());
                } finally {
                  setState(() {
                    isLoading = false; // Stop loading indicator
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editLabelName(String labelId) async {
    final newLabelNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Label Name'),
          content: TextField(
            controller: newLabelNameController,
            decoration: InputDecoration(hintText: "Enter new label name"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  setState(() {
                    isLoading = true; // start loading indicator
                  });
                  await LabelService.editLabelName(
                      labelId, newLabelNameController.text);
                  await fetchLabels();
                  Navigator.of(context).pop();
                } catch (e) {
                  showToast("error: " + e.toString());
                } finally {
                  setState(() {
                    isLoading = false; // Stop loading indicator
                  });
                }
              },
              child: Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _setDefaultLabel(String labelId, bool isAccount) async {
    String oldDefaultLabel = labels
        .firstWhere((element) =>
            element.isDefault && (!element.isAccount || element.isAccount))
        .id;

    try {
      await LabelService.setDefaultLabel(labelId, oldDefaultLabel);
      await fetchLabels();
    } catch (e) {
      showToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isAuthenticated
          ? CustomAppBar(isAuthenticated: isAuthenticated)
          : null,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: LabelList(
                labels: labels,
                expandedIndex: _expandedIndex,
                subExpandedIndex: _subExpandedIndex,
                onExpansionChanged: _onExpansionChanged,
                onEditLabelName: _editLabelName,
                onSetDefaultLabel: _setDefaultLabel,
              ),
            ),
      bottomNavigationBar: isAuthenticated
          ? BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: _addLabel,
        backgroundColor: Colors.blue,
        elevation: 2, // Increase elevation for a raised effect
        tooltip: 'Add Label', // Optional tooltip
        child: Icon(
          Icons.add,
          size: 24, // Adjust icon size as needed
          color: Colors.white, // Icon color
        ),
      ),
    );
  }
}
