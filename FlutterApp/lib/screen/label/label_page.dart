import 'package:expense_tracker/widgets/bottom_nav_bar.dart'; // Import BottomNavBar
import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/custom_app_bar.dart';
import 'package:expense_tracker/functions/switches.dart';

class LabelsPage extends StatefulWidget {
  const LabelsPage({Key? key}) : super(key: key);

  @override
  _LabelsPageState createState() => _LabelsPageState();
}

class _LabelsPageState extends State<LabelsPage> {
  bool isAuthenticated = true; // Placeholder for authentication status
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switches(index, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isAuthenticated
          ? CustomAppBar(isAuthenticated: isAuthenticated)
          : null,
      body: Center(
        child: Text('Labels Page'),
      ),
      bottomNavigationBar: isAuthenticated
          ? BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            )
          : null,
    );
  }
}
