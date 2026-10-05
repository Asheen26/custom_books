import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class DeliveryChallansListViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> createChallan(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/api/delivery-challans/');
    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Create delivery challan request: $url\n$body',
        name: 'DeliveryChallansListViewModel',
      );

      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Create delivery challan response (${response.statusCode}): ${response.body}',
        name: 'DeliveryChallansListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Create delivery challan request error: $e',
        name: 'DeliveryChallansListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchOptions() async {
    final url = Uri.parse('$baseUrl/api/delivery-challans/options/');
    return _get(url, 'ChallanOptions');
  }

  Future<Map<String, dynamic>?> fetchChallanDetail(String challanId) async {
    final url = Uri.parse(
      '$baseUrl/api/delivery-challans/',
    ).replace(queryParameters: {'delivery_challan_id': challanId});
    return _get(url, 'ChallanDetail');
  }

  Future<Map<String, dynamic>?> fetchChallans({
    String? status,
    String? sortBy,
    String? sortOrder,
    String? search,
  }) async {
    final url = Uri.parse('$baseUrl/api/delivery-challans/').replace(
      queryParameters: {
        if (status != null && status.isNotEmpty && status != 'all')
          'status': status,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
        if (sortOrder != null && sortOrder.isNotEmpty) 'sort_order': sortOrder,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return _get(url, 'DeliveryChallans');
  }

  Future<Map<String, dynamic>?> _get(Uri url, String label) async {
    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ $label request: $url', name: 'DeliveryChallansListViewModel');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 $label response (${response.statusCode}): ${response.body}',
        name: 'DeliveryChallansListViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ $label request error: $e',
        name: 'DeliveryChallansListViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
