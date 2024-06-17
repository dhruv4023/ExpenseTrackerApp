// lib/services/label_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart
import 'package:expense_tracker/functions/auth_shared_preference.dart';

class LabelService {
  static String baseUrl = "$API_URL/label";

  static Future<void> addLabel(String labelName, bool isAccount) async {
    final url = Uri.parse('$baseUrl/add');
    
    final payload =
        jsonEncode({"labelName": labelName, "isAccount": isAccount});
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

  static Future<void> editLabelName(String labelId, String newLabelName) async {
    final url = Uri.parse(
        '$baseUrl/edit/name/wallet/${await retriveWalletId()}/label/$labelId');
    final payload = jsonEncode({"newLabelName": newLabelName});
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

  static Future<void> setDefaultLabel(
      String labelId, String oldDefaultLabel) async {
    final url = Uri.parse(
        '$baseUrl/set/default/$labelId/wallet/${await retriveWalletId()}/oldDefaultLabel/$oldDefaultLabel');
    final headers = {
      'Authorization': await retriveToken(),
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final response = await http.put(url, headers: headers);
    if (response.statusCode != 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      throw Exception('${responseData["message"]}');
    }
  }
}
