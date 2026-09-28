import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class BankingOptionsViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> fetchOptions({String? search}) async {
    final url = Uri.parse('$baseUrl/api/banking/options/').replace(
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Banking options request: $url',
          name: 'BankingOptionsViewModel');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Banking options response (${response.statusCode}): ${response.body}',
        name: 'BankingOptionsViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Banking options request error: $e',
        name: 'BankingOptionsViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
