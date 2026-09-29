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

  CustomerModel? _createdCustomer;
  CustomerModel? get createdCustomer => _createdCustomer;

  Future<bool> createCustomer(Map<String, dynamic> body) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final resp = await _vm.createCustomer(body);
    final int? status = resp?['_statusCode'] as int?;
    final bool ok =
        resp != null &&
        resp['success'] == true &&
        status != null &&
        status >= 200 &&
        status < 300;

    if (ok) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        _createdCustomer = CustomerModel.fromJson(data);
      }
    } else {
      _errorMessage = _extractError(resp);
      appLog(
        '⚠️ Create customer failed (status: $status): $_errorMessage',
        name: 'CustomerFormController',
      );
    }

    _isSaving = false;
    notifyListeners();
    return ok;
  }

  String _extractError(Map<String, dynamic>? resp) {
    if (resp == null) {
      return 'Could not save the customer. Please check your connection.';
    }
    final errors = resp['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final parts = <String>[];
      errors.forEach((key, value) {
        final detail = value is List ? value.join(', ') : value.toString();
        parts.add('$key: $detail');
      });
      return parts.join('\n');
    }
    return (resp['message'] ?? 'Could not save the customer. Please try again.')
        .toString();
  }
}
