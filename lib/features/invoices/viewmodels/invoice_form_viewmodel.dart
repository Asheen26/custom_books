import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

/// Handles POST /api/invoices/ (create) and PATCH /api/invoices/?invoice_id= (update).
class InvoiceFormViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  /// POST /api/invoices/ — creates a new invoice.
  Future<Map<String, dynamic>?> createInvoice(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/api/invoices/');
    return _request(
      method: 'POST',
      url: url,
      body: body,
      logTag: 'Create invoice',
    );
  }

  /// `PATCH /api/invoices/?invoice_id=<id>` — updates an existing invoice.
  Future<Map<String, dynamic>?> updateInvoice(
    String invoiceId,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/invoices/',
    ).replace(queryParameters: {'invoice_id': invoiceId});
    return _request(
      method: 'PATCH',
      url: url,
      body: body,
      logTag: 'Update invoice',
    );
  }

  // ── shared HTTP helper ────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> _request({
    required String method,
    required Uri url,
    required Map<String, dynamic> body,
    required String logTag,
  }) async {
    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ $logTag request: $url', name: 'InvoiceFormViewModel');

      final http.Response response;
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final encoded = jsonEncode(body);

      if (method == 'POST') {
        response = await http.post(url, headers: headers, body: encoded);
      } else {
        response = await http.patch(url, headers: headers, body: encoded);
      }

      appLog(
        '📦 $logTag response (${response.statusCode}): ${response.body}',
        name: 'InvoiceFormViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ $logTag error: $e',
        name: 'InvoiceFormViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
