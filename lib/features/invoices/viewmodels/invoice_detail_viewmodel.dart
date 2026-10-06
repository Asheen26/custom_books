import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

/// Handles GET /api/invoices/?invoice_id=<id> — single invoice fetch.
class InvoiceDetailViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> deleteInvoice(String invoiceId) async {
    final url = Uri.parse(
      '$baseUrl/api/invoices/',
    ).replace(queryParameters: {'invoice_id': invoiceId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Invoice delete request: $url', name: 'InvoiceDetailViewModel');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Invoice delete response (${response.statusCode}): ${response.body}',
        name: 'InvoiceDetailViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Invoice delete request error: $e',
        name: 'InvoiceDetailViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchInvoiceById(String invoiceId) async {
    final url = Uri.parse(
      '$baseUrl/api/invoices/',
    ).replace(queryParameters: {'invoice_id': invoiceId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Invoice detail request: $url', name: 'InvoiceDetailViewModel');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Invoice detail response (${response.statusCode}): ${response.body}',
        name: 'InvoiceDetailViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Invoice detail request error: $e',
        name: 'InvoiceDetailViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
