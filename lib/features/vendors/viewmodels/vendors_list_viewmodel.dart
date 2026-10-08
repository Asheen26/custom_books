import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class VendorsListViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  /// GET /api/vendors/
  ///
  /// Tab filtering  → [filter] param  (values: all | active | inactive)
  /// Status filter  → [status] param  (values: all_vendors | active | inactive)
  /// Sorting        → [sortBy] + [sortOrder] (e.g. created_time / desc)
  Future<Map<String, dynamic>?> fetchVendors({
    String? search,
    String? filter,
    String? status,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? pageSize,
  }) async {
    final url = Uri.parse('$baseUrl/api/vendors/').replace(
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (filter != null && filter.isNotEmpty) 'filter': filter,
        if (status != null && status.isNotEmpty) 'status': status,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
        if (sortOrder != null && sortOrder.isNotEmpty) 'sort_order': sortOrder,
        if (page != null) 'page': '$page',
        if (pageSize != null) 'page_size': '$pageSize',
      },
    );

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Vendors request: $url', name: 'VendorsListViewModel');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Vendors response (${response.statusCode}): ${response.body}',
        name: 'VendorsListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Vendors request error: $e',
        name: 'VendorsListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// GET /api/vendors/options/
  Future<Map<String, dynamic>?> fetchOptions() async {
    final url = Uri.parse('$baseUrl/api/vendors/options/');

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Vendor options request: $url', name: 'VendorsListViewModel');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Vendor options response (${response.statusCode})',
        name: 'VendorsListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Vendor options request error: $e',
        name: 'VendorsListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// GET /api/vendors/export/
  Future<http.Response?> exportVendors({String format = 'csv'}) async {
    final url = Uri.parse(
      '$baseUrl/api/vendors/export/',
    ).replace(queryParameters: {'format': format});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Export vendors request: $url', name: 'VendorsListViewModel');

      final response = await http.get(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      appLog(
        '📦 Export vendors response (${response.statusCode}), '
        'bytes: ${response.bodyBytes.length}',
        name: 'VendorsListViewModel',
      );

      return response;
    } catch (e, st) {
      appLog(
        '❌ Export vendors request error: $e',
        name: 'VendorsListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
