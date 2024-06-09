import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

void saveToken(String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

Future<String> retriveToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  return 'Bearer $token';
}

void saveUser(Map<String, dynamic> user) async {
  DateTime now = DateTime.now();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  
  await prefs.setString('user', jsonEncode(user));
  
  String walletId = "${user["username"]}_${now.year}"; // Construct wallet ID
  await prefs.setString('wallet_id', walletId); // Save wallet ID to SharedPreferences
}

Future<String?> retriveUserData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('user');
}
Future<String?> retriveWalletId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('wallet_id');
}
