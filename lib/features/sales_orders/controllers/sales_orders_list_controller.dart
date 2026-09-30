import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/sales_orders/models/sales_order_model.dart';
import 'package:custom_books/features/sales_orders/models/sales_orders_options_model.dart';
import 'package:custom_books/features/sales_orders/viewmodels/sales_orders_list_viewmodel.dart';
import 'package:flutter/material.dart';

class SalesOrdersListController extends ChangeNotifier {
  final _vm = SalesOrdersListViewModel();

  static const int _pageSize = 20;

  // ─── Options ──────────────────────────────────────────────────────────────

  bool _optionsLoading = false;
  bool get optionsLoading => _optionsLoading;

  SalesOrdersOptionsModel? _options;
  SalesOrdersOptionsModel? get options => _options;

  /// Tab counts from the options endpoint.
  Map<String, int> get counts => _options?.counts ?? {};

  /// Tab labels from the options endpoint (falls back to defaults).
  List<String> get tabLabels =>
      _options?.tabs.map((t) => t.label).toList() ??
      const ['All', 'Draft', 'Confirmed'];

  // ─── List state ───────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  List<SalesOrderModel> _orders = [];
  List<SalesOrderModel> get orders => List.unmodifiable(_orders);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  int _page = 1;
  bool _hasMore = false;
  bool get hasMore => _hasMore;

  // ─── Current request params ───────────────────────────────────────────────

  /// Tab filter key: 'all' | 'draft' | 'confirmed'
  String? _filter;

  /// Status filter from filter sheet (overrides tab)
  String? _statusFilter;

  String? _search;

  /// API sort field key e.g. 'created_time'
  String _sortBy = 'created_time';

  /// 'asc' | 'desc'
  String _sortOrder = 'desc';

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<void> loadOptions() async {
    _optionsLoading = true;
    notifyListeners();

    final resp = await _vm.fetchOptions();
    final int? statusCode = resp?['_statusCode'] as int?;

    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        _options = SalesOrdersOptionsModel.fromJson(data);
        // Apply default sort from options
        _sortBy = _options!.defaultSort.sortBy;
        _sortOrder = _options!.defaultSort.sortOrder;
        appLog('✅ Sales Orders options loaded', name: 'SalesOrdersListController');
      }
    } else {
      appLog(
        '⚠️ Sales Orders options fetch failed (status: $statusCode)',
        name: 'SalesOrdersListController',
      );
    }

    _optionsLoading = false;
    notifyListeners();
  }

  Future<void> loadFirstPage({
    String? filter,
    String? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    _filter = filter;
    _statusFilter = status;
    _search = search;
    if (sortBy != null) _sortBy = sortBy;
    if (sortOrder != null) _sortOrder = sortOrder;
    _page = 1;

    _isLoading = true;
    notifyListeners();

    final list = await _fetchPage(1);
    if (list != null) _orders = list;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final next = _page + 1;
    final list = await _fetchPage(next);
    if (list != null) {
      _orders = [..._orders, ...list];
      _page = next;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  Future<List<SalesOrderModel>?> _fetchPage(int page) async {
    final resp = await _vm.fetchSalesOrders(
      filter: _filter,
      status: _statusFilter,
      search: _search,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
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
          .map(SalesOrderModel.fromJson)
          .toList();
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Could not load sales orders. Please try again.')
              .toString();
      appLog(
        '⚠️ Sales Orders fetch failed (status: $statusCode)',
        name: 'SalesOrdersListController',
      );
      return null;
    }
  }
}
