import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/vendors/models/vendor_model.dart';
import 'package:custom_books/features/vendors/viewmodels/vendor_form_viewmodel.dart';
import 'package:flutter/material.dart';

class VendorFormController extends ChangeNotifier {
  final _vm = VendorFormViewModel();

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  VendorModel? _savedVendor;
  VendorModel? get savedVendor => _savedVendor;

  Future<bool> create(Map<String, dynamic> body) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    final ok = _handle(await _vm.createVendor(body), 'create');
    _isSaving = false;
    notifyListeners();
    return ok;
  }

  Future<bool> update(String vendorId, Map<String, dynamic> body) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    final ok = _handle(await _vm.updateVendor(vendorId, body), 'update');
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
      if (data != null) _savedVendor = VendorModel.fromJson(data);
      appLog('✅ Vendor $action succeeded', name: 'VendorFormController');
      return true;
    }
    _errorMessage = _extractError(resp, action);
    appLog(
      '⚠️ Vendor $action failed (status: $status): $_errorMessage',
      name: 'VendorFormController',
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
    return (resp['message'] ?? 'Could not $action vendor. Please try again.')
        .toString();
  }
}
