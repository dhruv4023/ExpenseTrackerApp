import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class DropController extends ChangeNotifier {
  String? _selectedValue;

  DropController(String? defaultValue) {
    _selectedValue = defaultValue;
  }

  String? get selectedValue => _selectedValue;

  set selectedValue(String? newValue) {
    _selectedValue = newValue;
    notifyListeners();
  }
}

Widget dropDownMenu(DropController dropController, Map<String, String> keyValues) {
  return ChangeNotifierProvider<DropController>.value(
    value: dropController,
    child: Consumer<DropController>(
      builder: (context, dropController, child) {
        return DropdownButton<String>(
          value: dropController.selectedValue,
          items: keyValues.entries
              .map<DropdownMenuItem<String>>((MapEntry<String, String> entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            dropController.selectedValue = newValue;
          },
        );
      },
    ),
  );
}
