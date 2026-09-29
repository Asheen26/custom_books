import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class CustomerDetailViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> fetchCustomerById(String customerId) async {
    final url = Uri.parse(
      '$baseUrl/api/customers/',
    ).replace(queryParameters: {'customer_id': customerId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Customer detail request: $url',
          name: 'CustomerDetailViewModel');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Customer detail response (${response.statusCode}): ${response.body}',
        name: 'CustomerDetailViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Customer detail request error: $e',
        name: 'CustomerDetailViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
