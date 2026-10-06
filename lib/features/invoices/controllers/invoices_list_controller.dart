import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/invoices/models/invoice_model.dart';
import 'package:custom_books/features/invoices/viewmodels/invoices_list_viewmodel.dart';
import 'package:flutter/material.dart';

/// Manages the invoices list state: pagination, filtering, sorting, search.
class InvoicesListController extends ChangeNotifier {
  final _vm = InvoicesListViewModel();

  static const int _pageSize = 20;

  // ── loading states ────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // ── data ──────────────────────────────────────────────────────────────────
  List<InvoiceModel> _invoices = [];
  List<InvoiceModel> get invoices => List.unmodifiable(_invoices);

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
  String? _sortBy;
  String? _sortOrder;
  String? _search;

  /// Resets to page 1 and reloads. Call whenever filters / sort / search change.
  Future<void> loadFirstPage({
    String? status,
    String? sortBy,
    String? sortOrder,
    String? search,
  }) async {
    _status = status;
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _search = search;
    _page = 1;

    _isLoading = true;
    notifyListeners();

    final list = await _fetchPage(1);
    if (list != null) {
      _invoices = list;
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
      _invoices = [..._invoices, ...list];
      _page = next;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<List<InvoiceModel>?> _fetchPage(int page) async {
    final resp = await _vm.fetchInvoices(
      status: _status,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
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
          .map(InvoiceModel.fromJson)
          .toList();
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Could not load invoices. Please try again.')
              .toString();
      appLog(
        '⚠️ Invoices fetch failed (status: $statusCode)',
        name: 'InvoicesListController',
      );
      return null;
    }
  }
}
