import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/payments_received/models/payment_received_model.dart';
import 'package:custom_books/features/payments_received/viewmodels/payment_received_form_viewmodel.dart';
import 'package:flutter/material.dart';

/// Manages the create-payment form: holds [isSaving] state, calls the
/// ViewModel, and returns `null` on success or an error string on failure —
/// the same contract used by [InvoiceFormController].
class PaymentReceivedFormController extends ChangeNotifier {
  final _vm = PaymentReceivedFormViewModel();

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  /// POST /api/payments-received/
  ///
  /// Returns `null` on success (caller receives the created [PaymentReceivedModel]).
  /// Returns an error message string on failure.
  Future<({String? error, PaymentReceivedModel? payment})> create({
    required String customerId,
    required DateTime paymentDate,
    required PaymentMode paymentMode,
    required String referenceNumber,
    required double amount,
  }) async {
    return _submit(
      paymentId: null,
      customerId: customerId,
      paymentDate: paymentDate,
      paymentMode: paymentMode,
      referenceNumber: referenceNumber,
      amount: amount,
    );
  }

  /// PATCH `/api/payments-received/?payment_id=<id>`
  ///
  /// Returns `null` on success (caller receives the updated [PaymentReceivedModel]).
  /// Returns an error message string on failure.
  Future<({String? error, PaymentReceivedModel? payment})> update({
    required String paymentId,
    required String customerId,
    required DateTime paymentDate,
    required PaymentMode paymentMode,
    required String referenceNumber,
    required double amount,
  }) async {
    return _submit(
      paymentId: paymentId,
      customerId: customerId,
      paymentDate: paymentDate,
      paymentMode: paymentMode,
      referenceNumber: referenceNumber,
      amount: amount,
    );
  }

  // ── shared implementation ─────────────────────────────────────────────────
  Future<({String? error, PaymentReceivedModel? payment})> _submit({
    required String? paymentId,
    required String customerId,
    required DateTime paymentDate,
    required PaymentMode paymentMode,
    required String referenceNumber,
    required double amount,
  }) async {
    _isSaving = true;
    notifyListeners();

    final body = <String, dynamic>{
      'customer_id': customerId,
      'payment_date':
          '${paymentDate.year.toString().padLeft(4, '0')}-'
          '${paymentDate.month.toString().padLeft(2, '0')}-'
          '${paymentDate.day.toString().padLeft(2, '0')}',
      'payment_mode': paymentMode.apiKey,
      'reference_number': referenceNumber,
      'amount': amount.toStringAsFixed(2),
    };

    final bool isUpdate = paymentId != null;
    final String logLabel = isUpdate ? 'update' : 'create';

    try {
      final resp = isUpdate
          ? await _vm.updatePayment(paymentId, body)
          : await _vm.createPayment(body);
      final int? statusCode = resp?['_statusCode'] as int?;

      if (resp != null &&
          resp['success'] == true &&
          statusCode != null &&
          statusCode >= 200 &&
          statusCode < 300) {
        final data = resp['data'] as Map<String, dynamic>?;
        final payment = data != null
            ? PaymentReceivedModel.fromJson(data)
            : null;
        appLog(
          '✅ Payment $logLabel: ${payment?.paymentNumber}',
          name: 'PaymentReceivedFormController',
        );
        return (error: null, payment: payment);
      }

      final msg =
          (resp?['message'] ?? 'Could not $logLabel payment. Please try again.')
              .toString();
      appLog(
        '⚠️ Payment $logLabel failed (status: $statusCode): $msg',
        name: 'PaymentReceivedFormController',
      );
      return (error: msg, payment: null);
    } catch (e, st) {
      appLog(
        '❌ Payment $logLabel error: $e',
        name: 'PaymentReceivedFormController',
        error: e,
        stackTrace: st,
      );
      return (error: e.toString(), payment: null);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
