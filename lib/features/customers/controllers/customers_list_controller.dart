import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:custom_books/features/customers/models/customer_options_model.dart';
import 'package:custom_books/features/customers/viewmodels/customers_list_viewmodel.dart';
import 'package:flutter/material.dart';

class CustomersListController extends ChangeNotifier {
  final _vm = CustomersListViewModel();

  static const int _pageSize = 20;

  static const List<CustomerOption> _fallbackFilters = [
    CustomerOption(key: 'all_customers', label: 'All Customers'),
    CustomerOption(key: 'active_customers', label: 'Active Customers'),
    CustomerOption(key: 'crm_customers', label: 'CRM Customers'),
    CustomerOption(key: 'duplicate_customers', label: 'Duplicate Customers'),
    CustomerOption(key: 'inactive_customers', label: 'Inactive Customers'),
    CustomerOption(
      key: 'customer_portal_enabled',
      label: 'Customer Portal Enabled',
    ),
    CustomerOption(
      key: 'customer_portal_disabled',
      label: 'Customer Portal Disabled',
    ),
    CustomerOption(key: 'overdue_customers', label: 'Overdue Customers'),
    CustomerOption(key: 'unpaid_customers', label: 'Unpaid Customers'),
    CustomerOption(
      key: 'associated_with_payment_options',
      label: 'Associated with Payment Options',
    ),
  ];

  static const List<CustomerOption> _fallbackSortFields = [
    CustomerOption(key: 'name', label: 'Name'),
    CustomerOption(key: 'receivables', label: 'Receivables'),
    CustomerOption(key: 'unused_credits', label: 'Unused Credits'),
  ];

  List<CustomerOption> _filterOptions = _fallbackFilters;
  List<CustomerOption> get filterOptions => List.unmodifiable(_filterOptions);

  List<CustomerOption> _sortFieldOptions = _fallbackSortFields;
  List<CustomerOption> get sortFieldOptions =>
      List.unmodifiable(_sortFieldOptions);

  List<String> get filterLabels =>
      _filterOptions.map((o) => o.label).toList(growable: false);

  List<String> get sortFieldLabels =>
      _sortFieldOptions.map((o) => o.label).toList(growable: false);

  String? filterKeyForLabel(String label) {
    for (final o in _filterOptions) {
      if (o.label == label) return o.key;
    }
    return null;
  }

  String? sortKeyForLabel(String label) {
    for (final o in _sortFieldOptions) {
      if (o.label == label) return o.key;
    }
    return null;
  }

  Future<void> loadOptions() async {
    final resp = await _vm.fetchOptions();
    final int? status = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        status != null &&
        status >= 200 &&
        status < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        final options = CustomerOptionsModel.fromJson(data);
        if (options.filters.isNotEmpty) _filterOptions = options.filters;
        if (options.sortFields.isNotEmpty) {
          _sortFieldOptions = options.sortFields;
        }
        notifyListeners();
      }
    } else {
      appLog(
        '⚠️ Customer options fetch failed (status: $status); using fallbacks',
        name: 'CustomersListController',
      );
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => List.unmodifiable(_customers);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _page = 1;
  bool _hasMore = false;
  bool get hasMore => _hasMore;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  String? _filter;
  String? _sortBy;
  String? _sortOrder;
  String? _search;

  Future<void> loadFirstPage({
    String? filter,
    String? sortBy,
    String? sortOrder,
    String? search,
  }) async {
    _filter = filter;
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _search = search;
    _page = 1;

    _isLoading = true;
    notifyListeners();

    final list = await _fetchPage(1);
    if (list != null) {
      _customers = list;
    }

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
      _customers = [..._customers, ...list];
      _page = next;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<List<CustomerModel>?> _fetchPage(int page) async {
    final resp = await _vm.fetchCustomers(
      filter: _filter,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      search: _search,
      page: page,
      pageSize: _pageSize,
    );
    final int? status = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        status != null &&
        status >= 200 &&
        status < 300) {
      _errorMessage = null;
      final data = resp['data'] as Map<String, dynamic>?;
      _totalCount = (data?['count'] as num?)?.toInt() ?? 0;
      _hasMore = data?['next'] != null;
      final raw = (data?['results'] as List<dynamic>?) ?? [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(CustomerModel.fromJson)
          .toList();
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Could not load customers. Please try again.')
              .toString();
      appLog(
        '⚠️ Customers fetch failed (status: $status)',
        name: 'CustomersListController',
      );
      return null;
    }
  }
}
