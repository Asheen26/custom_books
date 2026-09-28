import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/banking/models/bank_transaction.dart';
import 'package:custom_books/features/banking/viewmodels/bank_transactions_viewmodel.dart';
import 'package:flutter/material.dart';

/// Loads and holds the transaction history for a single bank account.
class BankTransactionsController extends ChangeNotifier {
  BankTransactionsController(this.accountId, {this.fallbackCurrency});

  final String accountId;

  /// Currency to use when the API response omits a `currency` field.
  final String? fallbackCurrency;

  final _vm = BankTransactionsViewModel();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BankTransaction> _transactions = const [];
  List<BankTransaction> get transactions => _transactions;

  int _count = 0;
  int get count => _count;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> load({String? filter}) async {
    _isLoading = true;
    notifyListeners();
    await fetch(filter: filter);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetch({String? filter}) async {
    final resp = await _vm.fetchTransactions(
      accountId: accountId,
      filter: filter,
    );
    final int? status = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        status != null &&
        status >= 200 &&
        status < 300) {
      _errorMessage = null;
      final data = resp['data'] as Map<String, dynamic>?;
      final results = (data?['results'] as List<dynamic>?) ?? const [];
      _transactions = results.whereType<Map<String, dynamic>>().map((json) {
        // Inject the account currency as a fallback so amounts render with the
        // correct symbol when the API omits a per-transaction currency.
        if (fallbackCurrency != null &&
            fallbackCurrency!.isNotEmpty &&
            (json['currency'] == null ||
                json['currency'].toString().trim().isEmpty)) {
          json = {...json, 'currency': fallbackCurrency};
        }
        return BankTransaction.fromJson(json);
      }).toList();
      _count = (data?['count'] as num?)?.toInt() ?? _transactions.length;
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Could not load transactions. Please try again.')
              .toString();
      appLog(
        '⚠️ Bank transactions fetch failed (status: $status)',
        name: 'BankTransactionsController',
      );
    }
  }
}
