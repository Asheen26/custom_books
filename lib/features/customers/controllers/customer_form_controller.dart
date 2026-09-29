import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:custom_books/features/customers/viewmodels/customer_form_viewmodel.dart';
import 'package:flutter/material.dart';

class CustomerFormController extends ChangeNotifier {
  final _vm = CustomerFormViewModel();

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CustomerModel? _savedCustomer;
  CustomerModel? get savedCustomer => _savedCustomer;

  Future<bool> create(Map<String, dynamic> body) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    final ok = _handle(await _vm.createCustomer(body), 'create');
    _isSaving = false;
    notifyListeners();
    return ok;
  }

  Future<bool> update(String customerId, Map<String, dynamic> body) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    final ok = _handle(await _vm.updateCustomer(customerId, body), 'update');
    _isSaving = false;
    notifyListeners();
    return ok;
  }

  Future<bool> patch(String customerId, Map<String, dynamic> body) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    final ok = _handle(await _vm.patchCustomer(customerId, body), 'update');
    _isSaving = false;
    notifyListeners();
    return ok;
  }

  bool _handle(Map<String, dynamic>? resp, String action) {
    final int? status = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        status != null &&
        status >= 200 &&
        status < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) _savedCustomer = CustomerModel.fromJson(data);
      appLog('✅ Customer $action succeeded', name: 'CustomerFormController');
      return true;
    }
    _errorMessage = _extractError(resp, action);
    appLog(
      '⚠️ Customer $action failed (status: $status): $_errorMessage',
      name: 'CustomerFormController',
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
    return (resp['message'] ?? 'Could not $action customer. Please try again.')
        .toString();
  }
}
