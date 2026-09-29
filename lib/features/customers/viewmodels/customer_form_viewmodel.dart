import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class CustomerFormViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> createCustomer(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/api/customers/');

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Create customer request: $url', name: 'CustomerFormViewModel');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      appLog(
        '📦 Create customer response (${response.statusCode}): ${response.body}',
        name: 'CustomerFormViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Create customer request error: $e',
        name: 'CustomerFormViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateCustomer(
    String customerId,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/customers/',
    ).replace(queryParameters: {'customer_id': customerId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Update customer request: $url', name: 'CustomerFormViewModel');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      appLog(
        '📦 Update customer response (${response.statusCode}): ${response.body}',
        name: 'CustomerFormViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Update customer request error: $e',
        name: 'CustomerFormViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> patchCustomer(
    String customerId,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/customers/',
    ).replace(queryParameters: {'customer_id': customerId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Patch customer request: $url', name: 'CustomerFormViewModel');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      appLog(
        '📦 Patch customer response (${response.statusCode}): ${response.body}',
        name: 'CustomerFormViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Patch customer request error: $e',
        name: 'CustomerFormViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
