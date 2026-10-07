import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

/// Searches the items catalog for the Add Line Item picker
/// (`GET /api/items/?search=`).
class ItemLookupViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> searchItems(String search) async {
    final url = Uri.parse('$baseUrl/api/items/').replace(
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
      },
    );

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Item lookup request: $url', name: 'ItemLookupViewModel');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Item lookup response (${response.statusCode}): ${response.body}',
        name: 'ItemLookupViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Item lookup request error: $e',
        name: 'ItemLookupViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
