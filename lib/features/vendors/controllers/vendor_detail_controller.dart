import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/vendors/models/vendor_model.dart';
import 'package:custom_books/features/vendors/viewmodels/vendor_detail_viewmodel.dart';
import 'package:flutter/material.dart';

class VendorDetailController extends ChangeNotifier {
  final _vm = VendorDetailViewModel();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  VendorModel? _vendor;
  VendorModel? get vendor => _vendor;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> load(String vendorId) async {
    _isLoading = true;
    notifyListeners();

    final resp = await _vm.fetchVendorById(vendorId);
    final int? status = resp?['_statusCode'] as int?;

    if (resp != null &&
        resp['success'] == true &&
        status != null &&
        status >= 200 &&
        status < 300) {
      _errorMessage = null;
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        _vendor = VendorModel.fromJson(data);
      }
    } else {
      _errorMessage = (resp?['message'] ??
              'Could not load vendor details. Please try again.')
          .toString();
      appLog(
        '⚠️ Vendor detail fetch failed (status: $status)',
        name: 'VendorDetailController',
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}
