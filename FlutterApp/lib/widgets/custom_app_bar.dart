import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isAuthenticated;

  CustomAppBar({required this.isAuthenticated});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isSearching = false;

  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey,
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
