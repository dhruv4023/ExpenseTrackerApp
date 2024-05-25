import 'package:expense_tracker/widgets/SearchOnAppBar.dart';
import 'package:expense_tracker/screen/Login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isAuthenticated = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Remove token from SharedPreferences
    setState(() {
      _isAuthenticated = false; // Update authentication status
    });
  }

  Future<void> _checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SizedBox(
          child: _isAuthenticated ? _AppBar() : null,
        ),
      ),
      body: _isAuthenticated
          ? const Center(child: Text('Welcome to the Home Page!'))
          : LoginPage(), // Redirect to authentication page if not authenticated
    );
  }

  Widget _AppBar() {
    return AppBar(
      backgroundColor: Colors.grey,
      automaticallyImplyLeading: false,
      title:
          _isSearching ? buildSearchField() : const Text('Expense Tracker App'),
      actions: buildAppBarActions(_isSearching, toggleSearch, _logout),
    );
  }

  void toggleSearch(bool isSearching) {
    setState(() {
      _isSearching = isSearching;
    });
  }
}
