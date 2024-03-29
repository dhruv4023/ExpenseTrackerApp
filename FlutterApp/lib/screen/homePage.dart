import 'package:expense_tracker/widgets/SearchOnAppBar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearching = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _AppBar(),
      ),
      body: const Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }

  Widget _AppBar() {
    return AppBar(
      backgroundColor: Colors.grey,
      automaticallyImplyLeading: false,
      title:
          _isSearching ? buildSearchField() : const Text('Expense Tracker App'),
      actions: buildAppBarActions(_isSearching, toggleSearch),
    );
  }

  Widget buildNormalAppBar() {
    return AppBar(
      backgroundColor: Colors.grey,
      automaticallyImplyLeading: false,
      title:
          _isSearching ? buildSearchField() : const Text('Expense Tracker App'),
      actions: buildAppBarActions(_isSearching, toggleSearch),
    );
  }

  void toggleSearch(bool isSearching) {
    setState(() {
      _isSearching = isSearching;
    });
  }
}
