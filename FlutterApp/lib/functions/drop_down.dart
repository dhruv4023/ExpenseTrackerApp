import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String hintText;
  final String displayKey;
  final Map<String, dynamic>? defaultValue;
  final ValueChanged<Map<String, dynamic>> onChanged;

  CustomDropdown({
    required this.items,
    required this.hintText,
    required this.displayKey,
    this.defaultValue,
    required this.onChanged,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  Map<String, dynamic>? selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Map<String, dynamic>>(
      value: selectedItem,
      hint: Text(widget.hintText),
      items: widget.items.map((Map<String, dynamic> item) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: item,
          child: Text(item[widget.displayKey].toString()),
        );
      }).toList(),
      onChanged: (Map<String, dynamic>? newValue) {
        setState(() {
          selectedItem = newValue;
        });
        widget.onChanged(newValue!);
      },
    );
  }
}
