import 'package:expense_tracker/constants/colors.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      
      type: BottomNavigationBarType
          .fixed, // This is important for more than three items
      // backgroundColor: Colors
      //     .amberAccent, // Set background color for the whole BottomNavigationBar
      selectedItemColor: Colors.redAccent, // Color for selected item
      unselectedItemColor: tdFGColor, // Color for unselected items

      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.label),
          label: 'Labels',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
    );
  }
}
