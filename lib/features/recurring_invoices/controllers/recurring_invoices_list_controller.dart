import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/recurring_invoices/models/recurring_invoice_model.dart';
import 'package:custom_books/features/recurring_invoices/viewmodels/recurring_invoices_list_viewmodel.dart';
import 'package:flutter/material.dart';

/// Manages the recurring invoices list state: pagination, filtering, search.
class RecurringInvoicesListController extends ChangeNotifier {
  final _vm = RecurringInvoicesListViewModel();

  static const int _pageSize = 20;

  // ── loading states ────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // ── data ──────────────────────────────────────────────────────────────────
  List<RecurringInvoiceModel> _profiles = [];
  List<RecurringInvoiceModel> get profiles => List.unmodifiable(_profiles);

  int _totalCount = 0;
  int get totalCount => _totalCount;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── pagination state ─────────────────────────────────────────────────────
  int _page = 1;

  // ── current query params ─────────────────────────────────────────────────
  String? _status;
  String? _search;

  /// Resets to page 1 and reloads. Call whenever filters or search change.
  Future<void> loadFirstPage({String? status, String? search}) async {
    _status = status;
    _search = search;
    _page = 1;

    _isLoading = true;
    notifyListeners();

    final list = await _fetchPage(1);
    if (list != null) {
      _profiles = list;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Appends the next page when the user scrolls near the bottom.
  Future<void> loadNextPage() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final next = _page + 1;
    final list = await _fetchPage(next);
    if (list != null) {
      _profiles = [..._profiles, ...list];
      _page = next;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<List<RecurringInvoiceModel>?> _fetchPage(int page) async {
    final resp = await _vm.fetchRecurringInvoices(
      status: _status,
      search: _search,
      page: page,
      pageSize: _pageSize,
    );

    final int? statusCode = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      _errorMessage = null;
      final data = resp['data'] as Map<String, dynamic>?;
      _totalCount = (data?['count'] as num?)?.toInt() ?? 0;
      _hasMore = data?['next'] != null;
      final raw = (data?['results'] as List<dynamic>?) ?? [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(RecurringInvoiceModel.fromJson)
          .toList();
    } else {
      _errorMessage = (resp?['message'] ??
              'Could not load recurring invoices. Please try again.')
          .toString();
      appLog(
        '⚠️ Recurring invoices fetch failed (status: $statusCode)',
        name: 'RecurringInvoicesListController',
      );
      return null;
    }
  }
}
