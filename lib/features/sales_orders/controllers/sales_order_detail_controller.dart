import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/sales_orders/models/sales_order_model.dart';
import 'package:custom_books/features/sales_orders/viewmodels/sales_order_detail_viewmodel.dart';
import 'package:flutter/material.dart';

/// Manages the remote fetch and action calls for [SalesOrderDetailsPage].
///
/// Holds the currently displayed [SalesOrderModel] and exposes loading /
/// action-loading flags so the UI can react without managing state itself.
class SalesOrderDetailController extends ChangeNotifier {
  final _detailVm = SalesOrderDetailViewModel();

  // ── State ────────────────────────────────────────────────────────────────

  SalesOrderModel? _order;
  SalesOrderModel? get order => _order;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Seed ─────────────────────────────────────────────────────────────────

  /// Pre-populate with the lightweight model passed from the list page so the
  /// UI renders immediately while the full detail fetch runs.
  void seed(SalesOrderModel order) {
    _order = order;
  }

  // ── Load detail ───────────────────────────────────────────────────────────

  Future<void> load(String salesOrderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final resp = await _detailVm.fetchSalesOrderDetail(salesOrderId);
    final int? statusCode = resp?['_statusCode'] as int?;

    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        _order = SalesOrderModel.fromJson(data);
        appLog(
          '✅ Sales Order detail loaded: ${_order!.salesOrderNumber}',
          name: 'SalesOrderDetailController',
        );
      }
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Failed to load sales order details.')
              .toString();
      appLog(
        '⚠️ Sales Order detail fetch failed (status: $statusCode)',
        name: 'SalesOrderDetailController',
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Action loading flag ───────────────────────────────────────────────────

  void setActionLoading(bool value) {
    _isActionLoading = value;
    notifyListeners();
  }

  /// Update the in-memory order after a successful status action.
  void updateOrder(SalesOrderModel updated) {
    _order = updated;
    notifyListeners();
  }
}
