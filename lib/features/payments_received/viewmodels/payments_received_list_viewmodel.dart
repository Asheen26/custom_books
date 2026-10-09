import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

/// Handles GET /api/payments-received/ — listing, pagination, and options.
class PaymentsReceivedListViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> fetchPayments({
    String? search,
    String? sortBy,
    String? sortOrder,
    String? tab,
    String? mode,
    String? status,
    int? page,
    int? pageSize,
  }) async {
    final url = Uri.parse('$baseUrl/api/payments-received/').replace(
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
        if (sortOrder != null && sortOrder.isNotEmpty) 'sort_order': sortOrder,
        if (tab != null && tab.isNotEmpty && tab != 'all') 'tab': tab,
        if (mode != null && mode.isNotEmpty) 'mode': mode,
        if (status != null && status.isNotEmpty && status != 'all_statuses')
          'status': status,
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
    );

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Payments received request: $url',
        name: 'PaymentsReceivedListViewModel',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Payments received response (${response.statusCode}): ${response.body}',
        name: 'PaymentsReceivedListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Payments received request error: $e',
        name: 'PaymentsReceivedListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// GET `/api/payments-received/options/`
  Future<Map<String, dynamic>?> fetchOptions() async {
    final url = Uri.parse('$baseUrl/api/payments-received/options/');
    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Payments received options request: $url',
        name: 'PaymentsReceivedListViewModel',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Payments received options response (${response.statusCode})',
        name: 'PaymentsReceivedListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Payments received options request error: $e',
        name: 'PaymentsReceivedListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// `GET /api/payments-received/export/?export_format=<format>`
  ///
  /// [format] should be `'csv'` or `'json'`.
  Future<http.Response?> exportPayments({String format = 'csv'}) async {
    final url = Uri.parse(
      '$baseUrl/api/payments-received/export/',
    ).replace(queryParameters: {'export_format': format});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Export payments request: $url',
        name: 'PaymentsReceivedListViewModel',
      );

      final response = await http.get(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      appLog(
        '📦 Export payments response (${response.statusCode}), '
        'bytes: ${response.bodyBytes.length}',
        name: 'PaymentsReceivedListViewModel',
      );

      return response;
    } catch (e, st) {
      appLog(
        '❌ Export payments request error: $e',
        name: 'PaymentsReceivedListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
