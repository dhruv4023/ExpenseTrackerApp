import 'package:expense_tracker/constants/colors.dart';
import 'package:expense_tracker/widgets/base_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
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
  bool isLoading = false;
  List<Wallet> wallets = [];
  String? selectedWalletId;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    String token = await retriveToken();
    if (token.length > 15) fetchWallets();
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
          isLoading = false;
          if (wallets
              .any((wallet) => wallet.year == DateTime.now().year.toString())) {
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

  void _onWalletTapped(String walletId) async {
    await saveWalletId(walletId);
    setState(() {
      selectedWalletId = walletId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      widgetIndex: 0,
      body: _homeContent(),
      showBottonNavBar: selectedWalletId != null,
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
                    return Column(children: [
                      Divider(),
                      ListTile(
                        title: Text(wallet.year),
                        // subtitle: Text(wallet.year),
                        tileColor: isSelected ? tdBlue : null,
                        onTap: () => _onWalletTapped(wallet.id),
                      ),
                    ]);
                  },
                ),
              ),
            ],
          );
  }
}
