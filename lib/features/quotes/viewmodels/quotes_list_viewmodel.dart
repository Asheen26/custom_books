import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class QuotesListViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> fetchQuotes({
    String? status,
    String? filter,
    String? search,
    int? page,
    int? pageSize,
  }) async {
    final url = Uri.parse('$baseUrl/api/quotes/').replace(
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (filter != null && filter.isNotEmpty) 'filter': filter,
        if (search != null && search.isNotEmpty) 'search': search,
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
    );

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Quotes request: $url', name: 'QuotesListViewModel');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Quotes response (${response.statusCode}): ${response.body}',
        name: 'QuotesListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Quotes request error: $e',
        name: 'QuotesListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
