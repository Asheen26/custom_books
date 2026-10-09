import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

/// Handles POST and PATCH /api/payments-received/.
class PaymentReceivedFormViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  /// POST /api/payments-received/ — records a new payment.
  Future<Map<String, dynamic>?> createPayment(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/api/payments-received/');
    return _request(
      method: 'POST',
      url: url,
      body: body,
      logTag: 'Create payment',
    );
  }

  /// `PATCH /api/payments-received/?payment_id=<id>` — updates an existing payment.
  Future<Map<String, dynamic>?> updatePayment(
    String paymentId,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/payments-received/',
    ).replace(queryParameters: {'payment_id': paymentId});
    return _request(
      method: 'PATCH',
      url: url,
      body: body,
      logTag: 'Update payment',
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
      appLog('➡️ $logTag request: $url', name: 'PaymentReceivedFormViewModel');

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final encoded = jsonEncode(body);

      final http.Response response;
      if (method == 'POST') {
        response = await http.post(url, headers: headers, body: encoded);
      } else {
        response = await http.patch(url, headers: headers, body: encoded);
      }

      appLog(
        '📦 $logTag response (${response.statusCode}): ${response.body}',
        name: 'PaymentReceivedFormViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ $logTag error: $e',
        name: 'PaymentReceivedFormViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
