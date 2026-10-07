import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

/// Handles GET /api/recurring-invoices/ — listing and pagination only.
class RecurringInvoicesListViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> fetchRecurringInvoices({
    String? status,
    String? search,
    int? page,
    int? pageSize,
  }) async {
    final url = Uri.parse('$baseUrl/api/recurring-invoices/').replace(
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
    );

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Recurring invoices request: $url',
        name: 'RecurringInvoicesListViewModel',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Recurring invoices response (${response.statusCode}): ${response.body}',
        name: 'RecurringInvoicesListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Recurring invoices request error: $e',
        name: 'RecurringInvoicesListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
