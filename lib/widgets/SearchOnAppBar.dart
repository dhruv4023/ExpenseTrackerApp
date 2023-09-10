
import 'package:flutter/material.dart';

class MySearchAppBar extends StatefulWidget {
  const MySearchAppBar({super.key});

  @override
  _MySearchAppBarState createState() => _MySearchAppBarState();
}

class _MySearchAppBarState extends State<MySearchAppBar> {
  bool _isSearching = true;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching ? buildSearchField() :const Text('Expense Tracker App'),
      actions: buildAppBarActions(),
    );
  }

  List<Widget> buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            // Clear the search and return to the normal AppBar
            setState(() {
              _isSearching = false;
            });
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // Activate the search mode
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ];
    }
  }

  Widget buildSearchField() {
    return TextField(
      onChanged: (value) {
        // Handle search input here
      },
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
      ),
    );
  }
}
