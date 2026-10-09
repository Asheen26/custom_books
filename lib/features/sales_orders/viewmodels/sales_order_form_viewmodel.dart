import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

/// Handles create, update, delete, and status-action calls for a sales order.
/// Used by [AddSalesOrderPage], [SalesOrderDetailsPage], and
/// [SalesOrderActionsSheet].
class SalesOrderFormViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  // ─── Create ───────────────────────────────────────────────────────────────

  /// `POST /api/sales-orders/`
  Future<Map<String, dynamic>?> createSalesOrder(
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse('$baseUrl/api/sales-orders/');
    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Sales Order create request: $url', name: 'SalesOrderFormViewModel');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      appLog('📦 Sales Order create response (${response.statusCode}): ${response.body}', name: 'SalesOrderFormViewModel');
      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog('❌ Sales Order create error: $e', name: 'SalesOrderFormViewModel', error: e, stackTrace: st);
      return null;
    }
  }

  // ─── Update ───────────────────────────────────────────────────────────────

  /// `PUT /api/sales-orders/?sales_order_id=<id>`
  Future<Map<String, dynamic>?> updateSalesOrder(
    String salesOrderId,
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/sales-orders/',
    ).replace(queryParameters: {'sales_order_id': salesOrderId});
    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Sales Order update request: $url', name: 'SalesOrderFormViewModel');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      appLog('📦 Sales Order update response (${response.statusCode}): ${response.body}', name: 'SalesOrderFormViewModel');
      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog('❌ Sales Order update error: $e', name: 'SalesOrderFormViewModel', error: e, stackTrace: st);
      return null;
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  /// `DELETE /api/sales-orders/?sales_order_id=<id>`
  Future<Map<String, dynamic>?> deleteSalesOrder(String salesOrderId) async {
    final url = Uri.parse(
      '$baseUrl/api/sales-orders/',
    ).replace(queryParameters: {'sales_order_id': salesOrderId});
    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Sales Order delete request: $url', name: 'SalesOrderFormViewModel');
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      appLog('📦 Sales Order delete response (${response.statusCode}): ${response.body}', name: 'SalesOrderFormViewModel');
      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog('❌ Sales Order delete error: $e', name: 'SalesOrderFormViewModel', error: e, stackTrace: st);
      return null;
    }
  }

  // ─── Status Actions ───────────────────────────────────────────────────────

  /// `POST /api/sales-orders/confirm/?sales_order_id=<id>`
  Future<Map<String, dynamic>?> confirmSalesOrder(String salesOrderId) =>
      _postAction('confirm', salesOrderId);

  /// `POST /api/sales-orders/cancel/?sales_order_id=<id>`
  Future<Map<String, dynamic>?> cancelSalesOrder(String salesOrderId) =>
      _postAction('cancel', salesOrderId);

  /// `POST /api/sales-orders/mark-invoiced/?sales_order_id=<id>`
  Future<Map<String, dynamic>?> markSalesOrderInvoiced(String salesOrderId) =>
      _postAction('mark-invoiced', salesOrderId);

  Future<Map<String, dynamic>?> _postAction(
    String action,
    String salesOrderId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/sales-orders/$action/',
    ).replace(queryParameters: {'sales_order_id': salesOrderId});
    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Sales Order $action request: $url', name: 'SalesOrderFormViewModel');
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      appLog('📦 Sales Order $action response (${response.statusCode}): ${response.body}', name: 'SalesOrderFormViewModel');
      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog('❌ Sales Order $action error: $e', name: 'SalesOrderFormViewModel', error: e, stackTrace: st);
      return null;
    }
  }
}
