import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

/// Handles fetching the full detail of a single sales order.
/// Used by [SalesOrderDetailsPage].
class SalesOrderDetailViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  /// `GET /api/sales-orders/?sales_order_id=<id>`
  Future<Map<String, dynamic>?> fetchSalesOrderDetail(
    String salesOrderId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/sales-orders/',
    ).replace(queryParameters: {'sales_order_id': salesOrderId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Sales Order detail request: $url', name: 'SalesOrderDetailViewModel');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      appLog('📦 Sales Order detail response (${response.statusCode}): ${response.body}', name: 'SalesOrderDetailViewModel');
      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog('❌ Sales Order detail error: $e', name: 'SalesOrderDetailViewModel', error: e, stackTrace: st);
      return null;
    }
  }
}
