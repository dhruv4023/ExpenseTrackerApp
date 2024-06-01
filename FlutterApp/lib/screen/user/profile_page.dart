import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/widgets/custom_app_bar.dart';
import 'package:expense_tracker/functions/switches.dart';
import 'package:expense_tracker/widgets/bottom_nav_bar.dart';
import 'package:expense_tracker/screen/user/Login/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isAuthenticated = true; // Placeholder for authentication status
  int _selectedIndex = 0;
  Map<String, dynamic>? user; // User object to store retrieved user data

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      String? userJson = prefs.getString('user');

      if (userJson != null) {
        setState(() {
          user = (jsonDecode(userJson));
          isAuthenticated = true;
        });
      }
    } else {
      setState(() {
        isAuthenticated = false;
      });
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Remove token from SharedPreferences
    await prefs.remove('user'); // Remove user data from SharedPreferences
    setState(() {
      isAuthenticated = false; // Update authentication status
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
          ? _profileContent()
          : LoginPage(), // Redirect to authentication page if not authenticated
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _profileContent() {
    return user != null
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user?["picPath"] != null
                      ? NetworkImage(
                              'https://res.cloudinary.com/dbnmraxnj/image/upload/${user?["picPath"]}')
                          as ImageProvider
                      : AssetImage('assets/imgs/user.jpg'),
                ),
                const SizedBox(height: 16),
                Text(
                  user!["username"],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  user!["firstName"] + " " + user!["lastName"],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  user!["about"],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  user!["email"],
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text('Logout'),
                ),
              ],
            ),
          )
        : Center(child: CircularProgressIndicator());
  }
}
