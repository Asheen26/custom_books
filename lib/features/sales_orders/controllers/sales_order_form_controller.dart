import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/sales_orders/models/sales_order_model.dart';
import 'package:custom_books/features/sales_orders/viewmodels/sales_order_form_viewmodel.dart';
import 'package:flutter/material.dart';

/// Manages submitting state for [AddSalesOrderPage] and the
/// delete / status-action calls triggered from [SalesOrderDetailsPage]
/// and [SalesOrderActionsSheet].
class SalesOrderFormController extends ChangeNotifier {
  final _formVm = SalesOrderFormViewModel();

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Create ────────────────────────────────────────────────────────────────

  /// Returns the created [SalesOrderModel] on success, or `null` on failure.
  Future<SalesOrderModel?> create(Map<String, dynamic> payload) async {
    return _submit(() => _formVm.createSalesOrder(payload));
  }

  // ── Update ────────────────────────────────────────────────────────────────

  /// Returns the updated [SalesOrderModel] on success, or `null` on failure.
  Future<SalesOrderModel?> update(
    String salesOrderId,
    Map<String, dynamic> payload,
  ) async {
    return _submit(() => _formVm.updateSalesOrder(salesOrderId, payload));
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  /// Returns `null` on success, or an error message string on failure.
  Future<String?> delete(String salesOrderId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final resp = await _formVm.deleteSalesOrder(salesOrderId);
    final int? statusCode = resp?['_statusCode'] as int?;
    final bool ok = resp != null &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300;

    _isSubmitting = false;
    if (!ok) {
      _errorMessage =
          (resp?['message'] ?? 'Could not delete. Please try again.')
              .toString();
      appLog(
        '⚠️ Sales Order delete failed (status: $statusCode)',
        name: 'SalesOrderFormController',
      );
    } else {
      appLog('✅ Sales Order deleted', name: 'SalesOrderFormController');
    }
    notifyListeners();
    return ok ? null : _errorMessage;
  }

  // ── Status actions ────────────────────────────────────────────────────────

  /// Perform a status transition (confirm / cancel / mark-invoiced).
  ///
  /// Returns the updated [SalesOrderModel] on success, or `null` on failure.
  Future<SalesOrderModel?> performAction(String action, String id) async {
    final Future<Map<String, dynamic>?> call;
    switch (action) {
      case 'confirm':
        call = _formVm.confirmSalesOrder(id);
      case 'cancel':
        call = _formVm.cancelSalesOrder(id);
      case 'mark_invoiced':
        call = _formVm.markSalesOrderInvoiced(id);
      default:
        return null;
    }
    return _submit(() => call);
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<SalesOrderModel?> _submit(
    Future<Map<String, dynamic>?> Function() call,
  ) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final resp = await call();
    final int? statusCode = resp?['_statusCode'] as int?;
    SalesOrderModel? result;

    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) result = SalesOrderModel.fromJson(data);
      appLog(
        '✅ Sales Order form submit success',
        name: 'SalesOrderFormController',
      );
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Action failed. Please try again.').toString();
      appLog(
        '⚠️ Sales Order form submit failed (status: $statusCode)',
        name: 'SalesOrderFormController',
      );
    }

    _isSubmitting = false;
    notifyListeners();
    return result;
  }
}
