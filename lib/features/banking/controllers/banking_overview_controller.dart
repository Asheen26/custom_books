import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/banking/models/banking_overview.dart';
import 'package:custom_books/features/banking/viewmodels/banking_overview_viewmodel.dart';
import 'package:flutter/material.dart';

class BankingOverviewController extends ChangeNotifier {
  final _vm = BankingOverviewViewModel();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  BankingOverview? _overview;
  BankingOverview? get overview => _overview;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> load({String? dateRange, String? accountId}) async {
    _isLoading = true;
    notifyListeners();
    await fetch(dateRange: dateRange, accountId: accountId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetch({String? dateRange, String? accountId}) async {
    final resp = await _vm.fetchOverview(
      dateRange: dateRange,
      accountId: accountId,
    );
    final int? status = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        status != null &&
        status >= 200 &&
        status < 300) {
      _errorMessage = null;
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        _overview = BankingOverview.fromJson(data);
      }
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Could not load banking overview. Please try again.')
              .toString();
      appLog(
        '⚠️ Banking overview fetch failed (status: $status)',
        name: 'BankingOverviewController',
      );
    }
  }
}
