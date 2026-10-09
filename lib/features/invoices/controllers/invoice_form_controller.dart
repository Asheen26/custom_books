import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/invoices/viewmodels/invoice_form_viewmodel.dart';
import 'package:flutter/material.dart';

/// Manages the create / update invoice form state.
class InvoiceFormController extends ChangeNotifier {
  final _vm = InvoiceFormViewModel();

  // ── loading state ─────────────────────────────────────────────────────────
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  // ── Terms label → API key mapping ─────────────────────────────────────────
  static String termsToApiKey(String label) {
    switch (label) {
      case 'Net 15':
        return 'net_15';
      case 'Net 30':
        return 'net_30';
      case 'Net 45':
        return 'net_45';
      case 'Net 60':
        return 'net_60';
      case 'Due on Receipt':
      default:
        return 'due_on_receipt';
    }
  }

  /// POST /api/invoices/ with action = save_as_draft.
  /// Returns null on success, or an error message string on failure.
  Future<String?> saveAsDraft({
    required String customerId,
    required String placeOfSupply,
    required String invoiceDate,
    required String paymentTerms,
    String? subject,
    required String taxType,
    String? customerNotes,
    List<Map<String, dynamic>> lineItems = const [],
    String? orderNumber,
  }) => _submit(
    action: 'save_as_draft',
    customerId: customerId,
    placeOfSupply: placeOfSupply,
    invoiceDate: invoiceDate,
    paymentTerms: paymentTerms,
    subject: subject,
    taxType: taxType,
    customerNotes: customerNotes,
    lineItems: lineItems,
    orderNumber: orderNumber,
  );

  /// POST /api/invoices/ with action = save_and_send.
  /// Returns null on success, or an error message string on failure.
  Future<String?> saveAndSend({
    required String customerId,
    required String placeOfSupply,
    required String invoiceDate,
    required String paymentTerms,
    String? subject,
    required String taxType,
    String? customerNotes,
    List<Map<String, dynamic>> lineItems = const [],
    String? orderNumber,
  }) => _submit(
    action: 'save_and_send',
    customerId: customerId,
    placeOfSupply: placeOfSupply,
    invoiceDate: invoiceDate,
    paymentTerms: paymentTerms,
    subject: subject,
    taxType: taxType,
    customerNotes: customerNotes,
    lineItems: lineItems,
    orderNumber: orderNumber,
  );

  // ── shared implementation ─────────────────────────────────────────────────
  Future<String?> _submit({
    required String action,
    required String customerId,
    required String placeOfSupply,
    required String invoiceDate,
    required String paymentTerms,
    String? subject,
    required String taxType,
    String? customerNotes,
    List<Map<String, dynamic>> lineItems = const [],
    String? orderNumber,
  }) async {
    _isSaving = true;
    notifyListeners();

    final body = <String, dynamic>{
      'customer_id': customerId,
      'action': action,
      'place_of_supply': placeOfSupply,
      'invoice_date': invoiceDate,
      'payment_terms': paymentTerms,
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      'tax_type': taxType,
      if (customerNotes != null && customerNotes.isNotEmpty)
        'customer_notes': customerNotes,
      if (orderNumber != null && orderNumber.isNotEmpty)
        'order_number': orderNumber,
      'line_items': lineItems,
    };

    try {
      final resp = await _vm.createInvoice(body);
      final int? statusCode = resp?['_statusCode'] as int?;

      if (resp != null &&
          resp['success'] == true &&
          statusCode != null &&
          statusCode >= 200 &&
          statusCode < 300) {
        appLog(
          '✅ Invoice submitted (action: $action)',
          name: 'InvoiceFormController',
        );
        return null; // success
      } else {
        final msg =
            (resp?['message'] ?? 'Could not create invoice. Please try again.')
                .toString();
        appLog(
          '⚠️ Invoice submit failed (action: $action, status: $statusCode): $msg',
          name: 'InvoiceFormController',
        );
        return msg;
      }
    } catch (e, st) {
      appLog(
        '❌ Invoice submit error: $e',
        name: 'InvoiceFormController',
        error: e,
        stackTrace: st,
      );
      return e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// `PATCH /api/invoices/?invoice_id=<id>` — updates an existing invoice.
  /// Returns null on success, or an error message string on failure.
  Future<String?> update({
    required String invoiceId,
    required String customerId,
    required String placeOfSupply,
    required String invoiceDate,
    required String paymentTerms,
    String? subject,
    required String taxType,
    String? customerNotes,
    List<Map<String, dynamic>> lineItems = const [],
    String? orderNumber,
  }) async {
    _isSaving = true;
    notifyListeners();

    final body = <String, dynamic>{
      'customer_id': customerId,
      'place_of_supply': placeOfSupply,
      'invoice_date': invoiceDate,
      'payment_terms': paymentTerms,
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      'tax_type': taxType,
      if (customerNotes != null && customerNotes.isNotEmpty)
        'customer_notes': customerNotes,
      if (orderNumber != null && orderNumber.isNotEmpty)
        'order_number': orderNumber,
      'line_items': lineItems,
    };

    try {
      final resp = await _vm.updateInvoice(invoiceId, body);
      final int? statusCode = resp?['_statusCode'] as int?;

      if (resp != null &&
          resp['success'] == true &&
          statusCode != null &&
          statusCode >= 200 &&
          statusCode < 300) {
        appLog(
          '✅ Invoice updated successfully (id: $invoiceId)',
          name: 'InvoiceFormController',
        );
        return null; // success
      } else {
        final msg =
            (resp?['message'] ?? 'Could not update invoice. Please try again.')
                .toString();
        appLog(
          '⚠️ Invoice update failed (status: $statusCode): $msg',
          name: 'InvoiceFormController',
        );
        return msg;
      }
    } catch (e, st) {
      appLog(
        '❌ Invoice update error: $e',
        name: 'InvoiceFormController',
        error: e,
        stackTrace: st,
      );
      return e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
