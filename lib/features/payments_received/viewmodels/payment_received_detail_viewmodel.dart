import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

/// Handles single-payment operations: fetch by ID, void.
class PaymentReceivedDetailViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  /// GET `/api/payments-received/?payment_id=<id>`
  Future<Map<String, dynamic>?> fetchPaymentById(String paymentId) async {
    final url = Uri.parse(
      '$baseUrl/api/payments-received/',
    ).replace(queryParameters: {'payment_id': paymentId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Payment detail request: $url',
        name: 'PaymentReceivedDetailViewModel',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Payment detail response (${response.statusCode}): ${response.body}',
        name: 'PaymentReceivedDetailViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Payment detail request error: $e',
        name: 'PaymentReceivedDetailViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// POST `/api/payments-received/void/?payment_id=<id>`
  Future<Map<String, dynamic>?> voidPayment(String paymentId) async {
    final url = Uri.parse(
      '$baseUrl/api/payments-received/void/',
    ).replace(queryParameters: {'payment_id': paymentId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Void payment request: $url',
        name: 'PaymentReceivedDetailViewModel',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Void payment response (${response.statusCode}): ${response.body}',
        name: 'PaymentReceivedDetailViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Void payment request error: $e',
        name: 'PaymentReceivedDetailViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// DELETE `/api/payments-received/?payment_id=<id>`
  Future<Map<String, dynamic>?> deletePayment(String paymentId) async {
    final url = Uri.parse(
      '$baseUrl/api/payments-received/',
    ).replace(queryParameters: {'payment_id': paymentId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Delete payment request: $url',
        name: 'PaymentReceivedDetailViewModel',
      );

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Delete payment response (${response.statusCode}): ${response.body}',
        name: 'PaymentReceivedDetailViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Delete payment request error: $e',
        name: 'PaymentReceivedDetailViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
