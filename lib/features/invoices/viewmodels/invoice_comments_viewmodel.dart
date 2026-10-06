import 'dart:convert';

import 'package:custom_books/core/secrets/api_secrets.dart';
import 'package:custom_books/core/services/auth_service.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

/// Handles GET and POST for /api/invoices/comments/ with invoice_id query param.
class InvoiceCommentsViewModel {
  final String baseUrl = ApiSecrets.baseUrl;

  Uri _url(String invoiceId) => Uri.parse(
    '$baseUrl/api/invoices/comments/',
  ).replace(queryParameters: {'invoice_id': invoiceId});

  /// GET comments for the given invoice.
  Future<Map<String, dynamic>?> fetchComments(String invoiceId) async {
    final url = _url(invoiceId);
    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Invoice comments request: $url',
        name: 'InvoiceCommentsViewModel',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Invoice comments response (${response.statusCode})',
        name: 'InvoiceCommentsViewModel',
      );

      // Endpoint not implemented yet — treat as empty, no error.
      if (response.statusCode == 404) {
        return {'success': true, '_statusCode': 404, 'data': []};
      }

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        appLog(
          '⚠️ Invoice comments: unexpected content-type "$contentType"',
          name: 'InvoiceCommentsViewModel',
        );
        return {
          'success': false,
          '_statusCode': response.statusCode,
          'message': 'Unexpected response format',
        };
      }

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Invoice comments request error: $e',
        name: 'InvoiceCommentsViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// POST a new comment for the given invoice. Body: {"comment": text}
  Future<Map<String, dynamic>?> addComment(
    String invoiceId,
    String comment,
  ) async {
    final url = _url(invoiceId);
    try {
      final token = await AuthService.instance.getValidAccessToken();
      appLog(
        '➡️ Add invoice comment request: $url',
        name: 'InvoiceCommentsViewModel',
      );

      final response = await http.post(
        url,
        body: jsonEncode({'comment': comment}),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      appLog(
        '📦 Add invoice comment response (${response.statusCode})',
        name: 'InvoiceCommentsViewModel',
      );

      if (response.statusCode == 404) {
        return {
          'success': false,
          '_statusCode': 404,
          'message': 'Comments API is not available yet.',
        };
      }

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        return {
          'success': false,
          '_statusCode': response.statusCode,
          'message': 'Unexpected response format',
        };
      }

      final Map<String, dynamic> resp = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      resp['_statusCode'] = response.statusCode;
      return resp;
    } catch (e, st) {
      appLog(
        '❌ Add invoice comment error: $e',
        name: 'InvoiceCommentsViewModel',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
