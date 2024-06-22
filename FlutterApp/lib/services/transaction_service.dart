import 'dart:convert';
import 'package:expense_tracker/functions/datetime.dart';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart
import 'package:expense_tracker/functions/auth_shared_preference.dart';

class TransactionService {
  static String baseUrl = "$API_URL/transaction";

  static Future<void> addTransaction(
      String comment, double amount, String accountId, String labelId) async {
    final url = Uri.parse('$baseUrl/add');
    final payload = jsonEncode({
      "comment": comment,
      "amt": amount,
      "accountId": accountId,
      "labelId": labelId,
      "dateTime": getCurrentDateTimeFormatted()
    });
    final headers = {
      'Authorization': await retriveToken(),
      'Content-Type': 'application/json',
    };

    final response = await http.post(url, headers: headers, body: payload);
    if (response.statusCode != 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      throw Exception('${responseData["message"]}');
    }
  }

  static Future<void> editTransactionComment(
      String transactionId, String newComment) async {
    String? walletId = await retriveWalletId();
    final url =
        Uri.parse('$baseUrl/$transactionId/edit/comment/wallet/$walletId');
    final payload = jsonEncode({
      "comment": newComment,
    });
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

  static Future<void> editTransactionLabel(
      String transactionId, String newLabelId) async {
    String? walletId = await retriveWalletId();
    final url =
        Uri.parse('$baseUrl/$transactionId/edit/labelname/wallet/$walletId');
    final payload = jsonEncode({
      "newLabelId": newLabelId,
    });
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

  static Future<void> deleteTransaction(String transactionId) async {
    String? walletId = await retriveWalletId();
    final url = Uri.parse('$baseUrl/$transactionId/delete/wallet/$walletId');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': await retriveToken(),
    };

    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      throw Exception('${responseData["message"]}');
    }
  }
}
