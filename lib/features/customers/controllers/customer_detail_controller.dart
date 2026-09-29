import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:custom_books/features/customers/viewmodels/customer_detail_viewmodel.dart';
import 'package:flutter/material.dart';

class CustomerDetailController extends ChangeNotifier {
  final _vm = CustomerDetailViewModel();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CustomerModel? _customer;
  CustomerModel? get customer => _customer;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> load(String customerId) async {
    _isLoading = true;
    notifyListeners();

    final resp = await _vm.fetchCustomerById(customerId);
    final int? status = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        status != null &&
        status >= 200 &&
        status < 300) {
      _errorMessage = null;
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        _customer = CustomerModel.fromJson(data);
      }
    } else {
      _errorMessage =
          (resp?['message'] ??
                  'Could not load customer details. Please try again.')
              .toString();
      appLog(
        '⚠️ Customer detail fetch failed (status: $status)',
        name: 'CustomerDetailController',
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}
