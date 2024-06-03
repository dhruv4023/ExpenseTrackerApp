import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/Models/Transactions.dart';
import 'package:expense_tracker/screen/auth_user/Login/login_page.dart';
import 'package:expense_tracker/widgets/custom_app_bar.dart';
import 'package:expense_tracker/widgets/bottom_nav_bar.dart'; // Import BottomNavBar
import 'package:expense_tracker/functions/switches.dart'; // Import BottomNavBar
import 'package:expense_tracker/screen/home/widgets/tnxs_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAuthenticated = false; // false;
  int _selectedIndex = 1;

  final transactions = [
    Transaction(
      id: '1',
      dateTime: '2024-05-26 14:00',
      comment: 'Groceries',
      labelId: 'label1',
      amt: 100,
    ),
    Transaction(
      id: '2',
      dateTime: '2024-05-27 16:00',
      comment: 'Rent',
      labelId: 'label2',
      amt: 500,
    ),
    // Add more transactions here
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      isAuthenticated = token != null && token.isNotEmpty;
    });
  }

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
      body: isAuthenticated
          ? _homeContent()
          : LoginPage(), // Redirect to authentication page if not authenticated
      bottomNavigationBar: isAuthenticated
          ? BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            )
          : null,
    );
  }

  Widget _homeContent() {
    return Column(
      children: [
        // Container(
        //   child: Title(
        //       color: Colors.black26, child: const Text("All Transactions")),
        // ),
        Expanded(child: TnxWidget(transactions: transactions)),
      ],
    );
  }
}
