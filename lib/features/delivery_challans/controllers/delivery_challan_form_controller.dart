import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/delivery_challans/models/delivery_challan_model.dart';
import 'package:custom_books/features/delivery_challans/viewmodels/delivery_challans_list_viewmodel.dart';
import 'package:flutter/material.dart';

/// Handles the create (and future edit) submission for a single delivery challan.
class DeliveryChallanFormController extends ChangeNotifier {
  final _vm = DeliveryChallansListViewModel();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  static String _actionFor(DeliveryChallanStatus status) {
    switch (status) {
      case DeliveryChallanStatus.delivered:
        return 'save_as_delivered';
      case DeliveryChallanStatus.draft:
      default:
        return 'save_as_draft';
    }
  }

  static String _challanTypeFor(String label) {
    switch (label.toLowerCase()) {
      case 'supply on approval':
        return 'supply_on_approval';
      case 'others':
        return 'others';
      case 'job work':
      default:
        return 'job_work';
    }
  }

  Future<DeliveryChallanModel?> create({
    required String customerId,
    required String referenceNumber,
    required DateTime challanDate,
    required String type,
    required List<DeliveryChallanLineItem> lineItems,
    DeliveryChallanStatus status = DeliveryChallanStatus.draft,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final body = <String, dynamic>{
      'customer_id': customerId,
      'action': _actionFor(status),
      if (referenceNumber.isNotEmpty) 'reference_number': referenceNumber,
      'challan_date':
          '${challanDate.year.toString().padLeft(4, '0')}-'
          '${challanDate.month.toString().padLeft(2, '0')}-'
          '${challanDate.day.toString().padLeft(2, '0')}',
      'challan_type': _challanTypeFor(type),
      'line_items': lineItems
          .map(
            (i) => {
              'item_id': i.itemId,
              'quantity': i.quantity.toStringAsFixed(2),
              'rate': i.rate.toStringAsFixed(2),
            },
          )
          .toList(),
    };

    final resp = await _vm.createChallan(body);
    final int? statusCode = resp?['_statusCode'] as int?;

    DeliveryChallanModel? result;

    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      _errorMessage = null;
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        result = DeliveryChallanModel.fromJson(data);
      }
    } else {
      _errorMessage =
          (resp?['message'] ??
                  'Could not create delivery challan. Please try again.')
              .toString();
      appLog(
        '⚠️ Delivery challan create failed (status: $statusCode)',
        name: 'DeliveryChallanFormController',
      );
    }

    _isSubmitting = false;
    notifyListeners();
    return result;
  }
}
