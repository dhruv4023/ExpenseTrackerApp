import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart
import 'package:expense_tracker/functions/auth_shared_preference.dart';

class AccountService {
  static String baseUrl = "$API_URL/account";

  static Future<void> addAccount(String accountName, double openingBalance) async {
    String? walletId = await retriveWalletId();
    final url = Uri.parse('$baseUrl/add/wallet/$walletId');
    final payload = jsonEncode({
      "accountName": accountName,
      "openingBalance": openingBalance,
    });
    final headers = {
      'Authorization': await retriveToken(),
      'Content-Type': 'application/json',
    };

    final response = await http.post(url, headers: headers, body: payload);
    if (response.statusCode != 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      throw Exception('Error: ${responseData["message"]}');
    }
  }

  static Future<void> editAccountName(String accountId, String newAccountName) async {
    final url = Uri.parse('$baseUrl/edit/name/wallet/${await retriveWalletId()}/account/$accountId');
    final payload = jsonEncode({"newAccountName": newAccountName});
    final headers = {
      'Authorization': await retriveToken(),
      'Content-Type': 'application/json',
    };

    final response = await http.put(url, headers: headers, body: payload);
    if (response.statusCode != 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      throw Exception('${responseData["message"]}');
    }
  }

  static Future<void> setDefaultAccount(String accountId) async {
    String? walletId = await retriveWalletId();
    final url = Uri.parse('$baseUrl/set/default/$accountId/wallet/$walletId');
    final headers = {
      'Authorization': await retriveToken(),
      'Content-Type': 'application/json',
    };

    final response = await http.put(url, headers: headers);
    if (response.statusCode != 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      throw Exception('${responseData["message"]}');
    }
  }
}
