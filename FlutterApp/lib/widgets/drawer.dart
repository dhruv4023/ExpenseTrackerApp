import 'package:provider/provider.dart';
import 'package:expense_tracker/constants/colors.dart';
import 'package:expense_tracker/services/theme_notifier.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    void _logout() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // Remove token from SharedPreferences
      await prefs.remove('user'); // Remove user data from SharedPreferences

      Navigator.of(context).pushReplacementNamed('/home');
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Expense Tracker App',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            decoration: BoxDecoration(
              color: tdBlue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(
              themeNotifier.isDarkMode ? Icons.wb_sunny : Icons.brightness_2,
              color: themeNotifier.isDarkMode ? Colors.yellow : Colors.blue,
            ),
            title:
                Text(themeNotifier.isDarkMode ? 'Light Theme' : 'Dark Theme'),
            onTap: () {
              themeNotifier.toggleTheme();
            },
          ),
          ListTile(
            leading: Icon(Icons.close),
            title: Text('Close'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout_sharp),
            title: Text('Log Out'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
