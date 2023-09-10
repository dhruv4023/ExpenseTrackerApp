import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        automaticallyImplyLeading: false,
        title: _isSearching
            ? buildSearchField()
            : const Text('Expense Tracker App'),
        actions: buildAppBarActions(),
      ),
      body: const Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
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
          icon: const Icon(Icons.search),
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
}
