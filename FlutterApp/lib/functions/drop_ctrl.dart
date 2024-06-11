import 'package:flutter/material.dart';

class DropContr extends ChangeNotifier {
  String? _selectedValue;

  DropContr(String? defaultValue) {
    _selectedValue = defaultValue;
  }

  String? get selectedValue => _selectedValue;

  set selectedValue(String? newValue) {
    _selectedValue = newValue;
    notifyListeners();
  }
}
