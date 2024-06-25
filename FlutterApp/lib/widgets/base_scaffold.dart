import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:expense_tracker/screen/auth_user/Login/login_page.dart';
import 'package:expense_tracker/widgets/custom_app_bar.dart';
import 'package:expense_tracker/widgets/bottom_nav_bar.dart';
import 'package:expense_tracker/widgets/drawer.dart';
import 'package:expense_tracker/functions/switches.dart';
import 'package:expense_tracker/Models/Wallet.dart';

class BaseScaffold extends StatefulWidget {
  final Widget body;
  final Widget? floatingActionButton;
  final bool? showBottonNavBar;
  final int widgetIndex;

  BaseScaffold({
    required this.body,
    required this.widgetIndex,
    this.floatingActionButton,
    this.showBottonNavBar,
  });

  @override
  _BaseScaffoldState createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  bool isAuthenticated = false;
  bool isLoading = false;
  List<Wallet> wallets = [];
  bool walletForCurrentYearExists = false;
  String? selectedWalletId;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void updateAuthentication(bool value) {
    setState(() {
      isAuthenticated = value;
    });
  }

  Future<void> _checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      setState(() {
        isAuthenticated = true;
      });

      setState(() {
        selectedWalletId = selectedWalletId;
      }); // Update state to reflect the retrieved wallet ID
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          isAuthenticated ? MyAppBar(isAuthenticated: isAuthenticated) : null,
      body: !isAuthenticated
          ? LoginPage() // Redirect to authentication page if not authenticated
          : isLoading
              ? Center(child: CircularProgressIndicator())
              : widget.body,
      drawer: CustomDrawer(),
      bottomNavigationBar:
          (widget.showBottonNavBar == null || widget.showBottonNavBar == true)
              && isAuthenticated
                  ? BottomNavBar(
                      selectedIndex: widget.widgetIndex,
                      onItemTapped: (int index) {
                        switches(index, context);
                      },
                    )
                  : null
              ,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
