import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class VendorFormViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Future<Map<String, dynamic>?> createVendor(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/api/vendors/');

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Create vendor request: $url', name: 'VendorFormViewModel');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      appLog(
        '📦 Create vendor response (${response.statusCode}): ${response.body}',
        name: 'VendorFormViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Create vendor request error: $e',
        name: 'VendorFormViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateVendor(
    String vendorId,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/vendors/',
    ).replace(queryParameters: {'vendor_id': vendorId});

    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog('➡️ Update vendor request: $url', name: 'VendorFormViewModel');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      appLog(
        '📦 Update vendor response (${response.statusCode}): ${response.body}',
        name: 'VendorFormViewModel',
      );

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Update vendor request error: $e',
        name: 'VendorFormViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
