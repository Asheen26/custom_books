import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class BankingOverviewViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> fetchOverview({
    String? dateRange,
    String? accountId,
  }) async {
    final url = Uri.parse('$baseUrl/api/banking/overview/').replace(
      queryParameters: {
        if (dateRange != null && dateRange.isNotEmpty) 'date_range': dateRange,
        if (accountId != null && accountId.isNotEmpty) 'account_id': accountId,
      },
    );

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Banking overview request: $url',
          name: 'BankingOverviewViewModel');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Banking overview response (${response.statusCode}): ${response.body}',
        name: 'BankingOverviewViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Banking overview request error: $e',
        name: 'BankingOverviewViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
