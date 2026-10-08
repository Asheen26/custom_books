import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class VendorDetailViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  /// GET /api/vendors/?vendor_id={vendorId}
  Future<Map<String, dynamic>?> fetchVendorById(String vendorId) async {
    final url = Uri.parse(
      '$baseUrl/api/vendors/',
    ).replace(queryParameters: {'vendor_id': vendorId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Vendor detail request: $url', name: 'VendorDetailViewModel');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Vendor detail response (${response.statusCode}): ${response.body}',
        name: 'VendorDetailViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Vendor detail request error: $e',
        name: 'VendorDetailViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
