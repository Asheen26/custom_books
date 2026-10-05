import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

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

  // ─── Detail ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchSalesOrderDetail(
    String salesOrderId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/sales-orders/',
    ).replace(queryParameters: {'sales_order_id': salesOrderId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Sales Order detail request: $url',
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
        '📦 Sales Order detail response (${response.statusCode}): ${response.body}',
        name: 'SalesOrdersListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Sales Order detail request error: $e',
        name: 'SalesOrdersListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  // ─── Create ───────────────────────────────────────────────────────────────

  /// POST /api/sales-orders/
  Future<Map<String, dynamic>?> createSalesOrder(
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse('$baseUrl/api/sales-orders/');

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Sales Order create request: $url',
        name: 'SalesOrdersListViewModel',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      appLog(
        '📦 Sales Order create response (${response.statusCode}): ${response.body}',
        name: 'SalesOrdersListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Sales Order create error: $e',
        name: 'SalesOrdersListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  // ─── Update ───────────────────────────────────────────────────────────────

  /// PUT /api/sales-orders/?sales_order_id=<id>
  Future<Map<String, dynamic>?> updateSalesOrder(
    String salesOrderId,
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/sales-orders/',
    ).replace(queryParameters: {'sales_order_id': salesOrderId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Sales Order update request: $url',
        name: 'SalesOrdersListViewModel',
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      appLog(
        '📦 Sales Order update response (${response.statusCode}): ${response.body}',
        name: 'SalesOrdersListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Sales Order update error: $e',
        name: 'SalesOrdersListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  // ─── Status Actions ───────────────────────────────────────────────────────

  /// POST /api/sales-orders/confirm/?sales_order_id=<id>
  Future<Map<String, dynamic>?> confirmSalesOrder(String salesOrderId) =>
      _postAction('confirm', salesOrderId);

  /// POST /api/sales-orders/cancel/?sales_order_id=<id>
  Future<Map<String, dynamic>?> cancelSalesOrder(String salesOrderId) =>
      _postAction('cancel', salesOrderId);

  /// POST /api/sales-orders/mark-invoiced/?sales_order_id=<id>
  Future<Map<String, dynamic>?> markSalesOrderInvoiced(String salesOrderId) =>
      _postAction('mark-invoiced', salesOrderId);

  /// DELETE /api/sales-orders/?sales_order_id=<id>
  Future<Map<String, dynamic>?> deleteSalesOrder(String salesOrderId) async {
    final url = Uri.parse(
      '$baseUrl/api/sales-orders/',
    ).replace(queryParameters: {'sales_order_id': salesOrderId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Sales Order delete request: $url',
        name: 'SalesOrdersListViewModel',
      );

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Sales Order delete response (${response.statusCode}): ${response.body}',
        name: 'SalesOrdersListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Sales Order delete error: $e',
        name: 'SalesOrdersListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> _postAction(
    String action,
    String salesOrderId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/sales-orders/$action/',
    ).replace(queryParameters: {'sales_order_id': salesOrderId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Sales Order $action request: $url',
        name: 'SalesOrdersListViewModel',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Sales Order $action response (${response.statusCode}): ${response.body}',
        name: 'SalesOrdersListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Sales Order $action error: $e',
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
