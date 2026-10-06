import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/invoices/models/invoice_model.dart';
import 'package:custom_books/features/invoices/viewmodels/invoice_detail_viewmodel.dart';
import 'package:flutter/material.dart';

/// Manages loading and holding a single invoice's detail state.
class InvoiceDetailController extends ChangeNotifier {
  final _vm = InvoiceDetailViewModel();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  InvoiceModel? _invoice;
  InvoiceModel? get invoice => _invoice;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Deletes the invoice with [invoiceId] via DELETE /api/invoices/?invoice_id=.
  /// Returns null on success, or an error message on failure.
  Future<String?> delete(String invoiceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final resp = await _vm.deleteInvoice(invoiceId);
      final int? statusCode = resp?['_statusCode'] as int?;

      if (resp != null &&
          statusCode != null &&
          statusCode >= 200 &&
          statusCode < 300) {
        appLog(
          '✅ Invoice deleted (id: $invoiceId)',
          name: 'InvoiceDetailController',
        );
        return null; // success
      } else {
        final msg =
            (resp?['message'] ?? 'Could not delete invoice. Please try again.')
                .toString();
        appLog(
          '⚠️ Invoice delete failed (status: $statusCode): $msg',
          name: 'InvoiceDetailController',
        );
        return msg;
      }
    } catch (e, st) {
      appLog(
        '❌ Invoice delete error: $e',
        name: 'InvoiceDetailController',
        error: e,
        stackTrace: st,
      );
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> load(String invoiceId) async {
    _isLoading = true;
    notifyListeners();

    final resp = await _vm.fetchInvoiceById(invoiceId);
    final int? statusCode = resp?['_statusCode'] as int?;

    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      _errorMessage = null;
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        _invoice = InvoiceModel.fromJson(data);
      }
    } else {
      _errorMessage =
          (resp?['message'] ??
                  'Could not load invoice details. Please try again.')
              .toString();
      appLog(
        '⚠️ Invoice detail fetch failed (status: $statusCode)',
        name: 'InvoiceDetailController',
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}
