import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/quotes/models/quote_model.dart';
import 'package:custom_books/features/quotes/viewmodels/quote_form_viewmodel.dart';
import 'package:flutter/material.dart';

class QuoteFormController extends ChangeNotifier {
  final _vm = QuoteFormViewModel();

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  QuoteModel? _savedQuote;
  QuoteModel? get savedQuote => _savedQuote;

  Future<bool> create(Map<String, dynamic> body) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final ok = await _handle(await _vm.createQuote(body), 'create');

    _isSaving = false;
    notifyListeners();
    return ok;
  }

  Future<bool> update(String quoteId, Map<String, dynamic> body) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final ok = await _handle(await _vm.updateQuote(quoteId, body), 'update');

    _isSaving = false;
    notifyListeners();
    return ok;
  }

  Future<bool> _handle(Map<String, dynamic>? resp, String action) async {
    final int? status = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        status != null &&
        status >= 200 &&
        status < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) _savedQuote = QuoteModel.fromJson(data);
      appLog('✅ Quote $action succeeded', name: 'QuoteFormController');
      return true;
    }
    _errorMessage = _extractError(resp, action);
    appLog(
      '⚠️ Quote $action failed (status: $status): $_errorMessage',
      name: 'QuoteFormController',
    );
    return false;
  }

  String _extractError(Map<String, dynamic>? resp, String action) {
    if (resp == null) {
      return 'Could not reach the server. Check your connection and try again.';
    }
    final errors = resp['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final parts = <String>[];
      errors.forEach((field, messages) {
        if (messages is List && messages.isNotEmpty) {
          parts.add(messages.first.toString());
        } else if (messages != null) {
          parts.add(messages.toString());
        }
      });
      if (parts.isNotEmpty) return parts.join('\n');
    }
    return (resp['message'] ?? 'Could not $action quote. Please try again.')
        .toString();
  }
}
