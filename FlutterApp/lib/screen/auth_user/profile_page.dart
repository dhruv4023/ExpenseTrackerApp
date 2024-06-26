import 'dart:convert';
import 'package:expense_tracker/functions/auth_shared_preference.dart';
import 'package:expense_tracker/widgets/base_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/screen/auth_user/Login/login_page.dart';
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart
import "package:expense_tracker/constants/colors.dart";

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user; // User object to store retrieved user data

  @override
  void initState() {
    super.initState();
    getUserdata();
  }

  void getUserdata() async {
    String? userJson = await retriveUserData();

    if (userJson != null) {
      setState(() {
        user = jsonDecode(userJson);
      });
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Remove token from SharedPreferences
    await prefs.remove('user'); // Remove user data from SharedPreferences

    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(user: user)),
    ).then((updatedUser) {
      if (updatedUser != null) {
        setState(() {
          user = updatedUser;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: _profileContent(),
      widgetIndex: 3,
      showBottonNavBar: false,
      floatingActionButton: user != null
          ? FloatingActionButton(
              onPressed: _navigateToEditProfile,
              child: Icon(
                Icons.edit,
                color: tdFGColor,
              ),
              backgroundColor: tdBlue,
            )
          : null,
    );
  }

  Widget _profileContent() {
    return user != null
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user?["picPath"] != null
                        ? NetworkImage(
                                '$REACT_APP_CLOUDINARY_IMG/${user?["picPath"]}')
                            as ImageProvider
                        : AssetImage('assets/imgs/user.jpg'),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    user!["username"],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "${user!["firstName"]} ${user!["lastName"]}",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    user!["about"],
                    style: TextStyle(fontSize: 16, color: tdGrey),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    user!["email"],
                    style: TextStyle(fontSize: 16, color: tdGrey),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _logout,
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          )
        : Center(child: CircularProgressIndicator());
  }
}
