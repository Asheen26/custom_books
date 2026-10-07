import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/payments_received/models/payment_received_model.dart';
import 'package:custom_books/features/payments_received/viewmodels/payment_received_detail_viewmodel.dart';
import 'package:flutter/material.dart';

/// Manages loading and holding a single payment's detail state.
class PaymentReceivedDetailController extends ChangeNotifier {
  final _vm = PaymentReceivedDetailViewModel();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PaymentReceivedModel? _payment;
  PaymentReceivedModel? get payment => _payment;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Load ─────────────────────────────────────────────────────────────────

  /// Fetches the payment with [paymentId] from the API.
  /// Seeds from [seed] immediately so the UI can render while the fetch is
  /// in-flight.
  Future<void> load(String paymentId, {PaymentReceivedModel? seed}) async {
    if (seed != null && _payment == null) {
      _payment = seed;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resp = await _vm.fetchPaymentById(paymentId);
      final int? statusCode = resp?['_statusCode'] as int?;

      if (resp != null &&
          resp['success'] == true &&
          statusCode != null &&
          statusCode >= 200 &&
          statusCode < 300) {
        final data = resp['data'] as Map<String, dynamic>?;
        if (data != null) {
          _payment = PaymentReceivedModel.fromJson(data);
        }
        appLog(
          '✅ Payment detail loaded: ${_payment?.paymentNumber}',
          name: 'PaymentReceivedDetailController',
        );
      } else {
        _errorMessage =
            (resp?['message'] ??
                    'Could not load payment details. Please try again.')
                .toString();
        appLog(
          '⚠️ Payment detail fetch failed (status: $statusCode): $_errorMessage',
          name: 'PaymentReceivedDetailController',
        );
      }
    } catch (e, st) {
      _errorMessage = e.toString();
      appLog(
        '❌ Payment detail load error: $e',
        name: 'PaymentReceivedDetailController',
        error: e,
        stackTrace: st,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Void ─────────────────────────────────────────────────────────────────

  /// POST `/api/payments-received/void/?payment_id=<id>`
  ///
  /// Returns `null` on success, or an error message string on failure.
  Future<String?> voidPayment(String paymentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final resp = await _vm.voidPayment(paymentId);
      final int? statusCode = resp?['_statusCode'] as int?;

      if (resp != null &&
          statusCode != null &&
          statusCode >= 200 &&
          statusCode < 300 &&
          resp['success'] == true) {
        final data = resp['data'] as Map<String, dynamic>?;
        if (data != null) {
          _payment = PaymentReceivedModel.fromJson(data);
        }
        appLog(
          '✅ Payment voided: $paymentId',
          name: 'PaymentReceivedDetailController',
        );
        return null;
      }

      final msg =
          (resp?['message'] ?? 'Could not void payment. Please try again.')
              .toString();
      appLog(
        '⚠️ Void payment failed (status: $statusCode): $msg',
        name: 'PaymentReceivedDetailController',
      );
      return msg;
    } catch (e, st) {
      appLog(
        '❌ Void payment error: $e',
        name: 'PaymentReceivedDetailController',
        error: e,
        stackTrace: st,
      );
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  /// DELETE `/api/payments-received/?payment_id=<id>`
  ///
  /// Returns `null` on success, or an error message string on failure.
  Future<String?> deletePayment(String paymentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final resp = await _vm.deletePayment(paymentId);
      final int? statusCode = resp?['_statusCode'] as int?;

      if (resp != null &&
          statusCode != null &&
          statusCode >= 200 &&
          statusCode < 300) {
        appLog(
          '✅ Payment deleted: $paymentId',
          name: 'PaymentReceivedDetailController',
        );
        return null;
      }

      final msg =
          (resp?['message'] ?? 'Could not delete payment. Please try again.')
              .toString();
      appLog(
        '⚠️ Delete payment failed (status: $statusCode): $msg',
        name: 'PaymentReceivedDetailController',
      );
      return msg;
    } catch (e, st) {
      appLog(
        '❌ Delete payment error: $e',
        name: 'PaymentReceivedDetailController',
        error: e,
        stackTrace: st,
      );
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
