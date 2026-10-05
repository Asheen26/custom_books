import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/delivery_challans/models/delivery_challan_model.dart';
import 'package:custom_books/features/delivery_challans/viewmodels/delivery_challans_list_viewmodel.dart';
import 'package:flutter/material.dart';

/// Manages fetching and holding the full detail of a single delivery challan.
class DeliveryChallanDetailController extends ChangeNotifier {
  final _vm = DeliveryChallansListViewModel();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DeliveryChallanModel? _challan;

  DeliveryChallanModel? get challan => _challan;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void seed(DeliveryChallanModel challan) {
    _challan = challan;
  }

  Future<void> load(String challanId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final resp = await _vm.fetchChallanDetail(challanId);
    final int? statusCode = resp?['_statusCode'] as int?;

    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        _challan = DeliveryChallanModel.fromJson(data);
      }
      _errorMessage = null;
    } else {
      _errorMessage =
          (resp?['message'] ??
                  'Could not load delivery challan details. Please try again.')
              .toString();
      appLog(
        '⚠️ Delivery challan detail fetch failed (status: $statusCode)',
        name: 'DeliveryChallanDetailController',
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}
