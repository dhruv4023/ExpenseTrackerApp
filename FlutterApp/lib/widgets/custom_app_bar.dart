import 'package:expense_tracker/constants/colors.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isAuthenticated;

  MyAppBar({required this.isAuthenticated});

  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  bool _isSearching = false;

  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      backgroundColor: tdGrey,
      automaticallyImplyLeading: false,
      title:
          _isSearching ? buildSearchField() : const Text('Expense Tracker App'),
      actions: buildAppBarActions(),
    );
  }

  Widget buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white60),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
    );
  }

  List<Widget> buildAppBarActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: toggleSearch,
        ),
      ];
    }
    return <Widget>[
      IconButton(
        icon: Icon(Icons.search),
        onPressed: toggleSearch,
      ),
    ];
  }
}
