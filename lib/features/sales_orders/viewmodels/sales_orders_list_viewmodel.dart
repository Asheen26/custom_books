import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

/// Handles the list page: fetching the paginated list and loading filter/sort
/// options from the server.
class SalesOrdersListViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  // ─── Options ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchOptions() async {
    final url = Uri.parse('$baseUrl/api/sales-orders/options/');
    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Sales Orders options request: $url',
        name: 'SalesOrdersListViewModel',
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      appLog(
        '📦 Sales Orders options response (${response.statusCode}): ${response.body}',
        name: 'SalesOrdersListViewModel',
      );
      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Sales Orders options error: $e',
        name: 'SalesOrdersListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  // ─── List ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchSalesOrders({
    /// Tab filter key: 'all' | 'draft' | 'confirmed'
    String? filter,

    /// Overrides tab — specific status filter from filter sheet
    String? status,
    String? search,

    /// API sort field key e.g. 'created_time', 'date', 'amount'
    String? sortBy,

    /// 'asc' | 'desc'
    String? sortOrder,
    int? page,
    int? pageSize,
  }) async {
    final url = Uri.parse('$baseUrl/api/sales-orders/').replace(
      queryParameters: {
        if (filter != null && filter.isNotEmpty) 'filter': filter,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
        if (sortOrder != null && sortOrder.isNotEmpty) 'sort_order': sortOrder,
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
    );
    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Sales Orders request: $url', name: 'SalesOrdersListViewModel');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      appLog(
        '📦 Sales Orders response (${response.statusCode}): ${response.body}',
        name: 'SalesOrdersListViewModel',
      );
      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Sales Orders request error: $e',
        name: 'SalesOrdersListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
