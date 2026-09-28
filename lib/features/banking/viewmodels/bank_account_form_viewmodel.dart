import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class BankAccountFormViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> createAccount(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/api/banking/accounts/');

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Create bank account request: $url',
        name: 'BankAccountFormViewModel',
      );

      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Create bank account response (${response.statusCode}): ${response.body}',
        name: 'BankAccountFormViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Create bank account request error: $e',
        name: 'BankAccountFormViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
