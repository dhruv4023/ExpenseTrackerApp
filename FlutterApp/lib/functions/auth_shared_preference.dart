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
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user', jsonEncode(user));
}

Future<String?> retriveUserData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('user');
}
