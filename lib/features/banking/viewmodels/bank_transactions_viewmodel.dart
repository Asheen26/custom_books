import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

/// Talks to the banking transactions API.
///
/// `GET /api/banking/transactions/?account_id=<id>` returns a paginated
/// payload of the form:
/// ```json
/// {
///   "success": true,
///   "message": "Success",
///   "data": { "count": 0, "next": null, "previous": null, "results": [] }
/// }
/// ```
class BankTransactionsViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> fetchTransactions({
    required String accountId,
    String? filter,
  }) async {
    final url = Uri.parse('$baseUrl/api/banking/transactions/').replace(
      queryParameters: {
        if (accountId.isNotEmpty) 'account_id': accountId,
        if (filter != null && filter.isNotEmpty) 'filter': filter,
      },
    );

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Bank transactions request: $url',
        name: 'BankTransactionsViewModel',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Bank transactions response (${response.statusCode}): ${response.body}',
        name: 'BankTransactionsViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Bank transactions request error: $e',
        name: 'BankTransactionsViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
