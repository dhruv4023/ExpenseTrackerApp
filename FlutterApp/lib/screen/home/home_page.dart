import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:expense_tracker/screen/auth_user/Login/login_page.dart';
import 'package:expense_tracker/widgets/custom_app_bar.dart';
import 'package:expense_tracker/widgets/bottom_nav_bar.dart';
import 'package:expense_tracker/functions/switches.dart';
import 'package:expense_tracker/config/ENV_VARS.dart';
import 'package:expense_tracker/functions/show_toast.dart';
import 'package:expense_tracker/functions/auth_shared_preference.dart';
import 'package:expense_tracker/Models/Wallet.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAuthenticated = false;
  bool isLoading = false;
  int _selectedIndex = 1;
  List<Wallet> wallets = [];
  bool walletForCurrentYearExists = false;
  String? selectedWalletId;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      setState(() {
        isAuthenticated = true;
      });
      await fetchWallets();
      selectedWalletId = await retriveWalletId();
      // print(selectedWalletId);

      setState(() {
        selectedWalletId = selectedWalletId;
      }); // Update state to reflect the retrieved wallet ID
    }
  }

  Future<void> fetchWallets() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$API_URL/wallet/get');
    final headers = {
      'Authorization': await retriveToken(),
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> walletsData = data['data']["wallets"];
        setState(() {
          wallets = walletsData.map((json) => Wallet.fromJson(json)).toList();
          walletForCurrentYearExists = wallets
              .any((wallet) => wallet.year == DateTime.now().year.toString());
          isLoading = false;
          if (walletForCurrentYearExists) {
            _onWalletTapped(wallets
                .firstWhere(
                    (element) => element.year == DateTime.now().year.toString())
                .id);
          }
        });
      } else {
        showToast('Failed to load wallets');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showToast(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> createWallet() async {
    final url = Uri.parse('$API_URL/wallet/create');
    final headers = {
      'Authorization': await retriveToken(),
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        showToast('Wallet created successfully');
        await fetchWallets();
      } else {
        showToast('Failed to create wallet');
      }
    } catch (e) {
      showToast(e.toString());
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switches(index, context);
  }

  void _onWalletTapped(String walletId) async {
    await saveWalletId(walletId);
    setState(() {
      selectedWalletId = walletId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isAuthenticated
          ? CustomAppBar(isAuthenticated: isAuthenticated)
          : null,
      body: !isAuthenticated
          ? LoginPage() // Redirect to authentication page if not authenticated
          :isLoading
          ? Center(child: CircularProgressIndicator())
           :_homeContent(),
      bottomNavigationBar: isAuthenticated
          ? BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            )
          : null,
      floatingActionButton: isAuthenticated && !walletForCurrentYearExists
          ? FloatingActionButton(
              onPressed: createWallet,
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }

  Widget _homeContent() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Your wallets",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = wallets[index];
                    final bool isSelected = wallet.id == selectedWalletId;
                    return ListTile(
                      title: Text(wallet.title),
                      subtitle: Text(wallet.year),
                      tileColor: isSelected ? Colors.blue[100] : null,
                      onTap: () => _onWalletTapped(wallet.id),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
