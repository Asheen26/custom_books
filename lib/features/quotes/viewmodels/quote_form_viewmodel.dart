import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class QuoteFormViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> createQuote(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/api/quotes/');

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Create quote request: $url', name: 'QuoteFormViewModel');
      appLog('📤 Body: ${jsonEncode(body)}', name: 'QuoteFormViewModel');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      appLog(
        '📦 Create quote response (${response.statusCode}): ${response.body}',
        name: 'QuoteFormViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Create quote request error: $e',
        name: 'QuoteFormViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateQuote(
    String quoteId,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/api/quotes/').replace(
      queryParameters: {'quote_id': quoteId},
    );

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Update quote request: $url', name: 'QuoteFormViewModel');
      appLog('📤 Body: ${jsonEncode(body)}', name: 'QuoteFormViewModel');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      appLog(
        '📦 Update quote response (${response.statusCode}): ${response.body}',
        name: 'QuoteFormViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Update quote request error: $e',
        name: 'QuoteFormViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
