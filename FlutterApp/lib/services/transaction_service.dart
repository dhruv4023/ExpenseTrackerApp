import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart
import 'package:expense_tracker/functions/auth_shared_preference.dart';

class TransactionService {
  static String baseUrl = "$API_URL/transaction";

  static Future<void> addTransaction(
      String comment, double amount, List<String> labelIds) async {
    final url = Uri.parse('$baseUrl/add');
    final payload = jsonEncode({
      "comment": comment,
      "amt": amount,
      "labelIds": labelIds,
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

  static Future<void> editTransactionLabels(
      String transactionId, List<String> newLabelIds) async {
    String? walletId = await retriveWalletId();
    final url =
        Uri.parse('$baseUrl/$transactionId/edit/labelname/wallet/$walletId');
    final payload = jsonEncode({
      "newLabelIds": newLabelIds,
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
      'Authorization': await retriveToken(),
    };

    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      throw Exception('${responseData["message"]}');
    }
  }
}
