import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class CustomersListViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> fetchCustomers({
    String? filter,
    String? sortBy,
    String? sortOrder,
    String? search,
    int? page,
    int? pageSize,
  }) async {
    final url = Uri.parse('$baseUrl/api/customers/').replace(
      queryParameters: {
        if (filter != null && filter.isNotEmpty) 'filter': filter,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
        if (sortOrder != null && sortOrder.isNotEmpty) 'sort_order': sortOrder,
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
    );

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Customers request: $url', name: 'CustomersListViewModel');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Customers response (${response.statusCode}): ${response.body}',
        name: 'CustomersListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Customers request error: $e',
        name: 'CustomersListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchOptions() async {
    final url = Uri.parse('$baseUrl/api/customers/options/');

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Customer options request: $url',
        name: 'CustomersListViewModel',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Customer options response (${response.statusCode})',
        name: 'CustomersListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Customer options request error: $e',
        name: 'CustomersListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<http.Response?> exportCustomers({String format = 'csv'}) async {
    final url = Uri.parse(
      '$baseUrl/api/customers/export/',
    ).replace(queryParameters: {'format': format});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Export customers request: $url',
        name: 'CustomersListViewModel',
      );

      final response = await http.get(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      appLog(
        '📦 Export customers response (${response.statusCode}), '
        'bytes: ${response.bodyBytes.length}',
        name: 'CustomersListViewModel',
      );

      return response;
    } catch (e, st) {
      appLog(
        '❌ Export customers request error: $e',
        name: 'CustomersListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
