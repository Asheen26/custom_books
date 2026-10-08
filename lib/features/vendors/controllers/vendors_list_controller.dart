import 'dart:io';

import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/vendors/models/vendor_model.dart';
import 'package:custom_books/features/vendors/models/vendor_options_model.dart';
import 'package:custom_books/features/vendors/viewmodels/vendors_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorsListController extends ChangeNotifier {
  final _vm = VendorsListViewModel();

  static const int _pageSize = 20;

  // ── Fallback options (used if the options call fails) ───────────────────────

  static const List<VendorOption> _fallbackTabs = [
    VendorOption(key: 'all', label: 'All'),
    VendorOption(key: 'active', label: 'Active'),
    VendorOption(key: 'inactive', label: 'Inactive'),
  ];

  static const List<VendorOption> _fallbackStatuses = [
    VendorOption(key: 'all_vendors', label: 'All Vendors'),
    VendorOption(key: 'active', label: 'ACTIVE'),
    VendorOption(key: 'inactive', label: 'INACTIVE'),
  ];

  static const List<VendorOption> _fallbackSortFields = [
    VendorOption(key: 'created_time', label: 'Created Time'),
    VendorOption(key: 'name', label: 'Name'),
    VendorOption(key: 'company_name', label: 'Company Name'),
    VendorOption(key: 'payables', label: 'Payables'),
  ];

  // ── Options state ───────────────────────────────────────────────────────────

  List<VendorOption> _tabs = _fallbackTabs;
  List<VendorOption> get tabs => List.unmodifiable(_tabs);

  List<VendorOption> _statuses = _fallbackStatuses;
  List<VendorOption> get statuses => List.unmodifiable(_statuses);

  List<VendorOption> _sortFields = _fallbackSortFields;
  List<VendorOption> get sortFields => List.unmodifiable(_sortFields);

  List<VendorAction> _actions = const [];
  List<VendorAction> get actions => List.unmodifiable(_actions);

  /// Per-tab counts from the options endpoint (e.g. {'all': 4, 'active': 3}).
  Map<String, int> _counts = const {};
  int countForTab(String key) => _counts[key] ?? 0;

  String _defaultSortBy = 'created_time';
  String _defaultSortOrder = 'desc';
  String get defaultSortBy => _defaultSortBy;
  String get defaultSortOrder => _defaultSortOrder;

  // ── Loading states ──────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // ── List data ───────────────────────────────────────────────────────────────

  List<VendorModel> _vendors = [];
  List<VendorModel> get vendors => List.unmodifiable(_vendors);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _page = 1;
  bool _hasMore = false;
  bool get hasMore => _hasMore;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  // ── Current query params ────────────────────────────────────────────────────

  String? _search;

  /// Tab filter key sent as `filter=` param (all | active | inactive).
  String? _filter;

  /// Status filter key sent as `status=` param (all_vendors | active | inactive).
  String? _status;

  String? _sortBy;
  String? _sortOrder;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Fetches options once on page open; uses fallbacks silently on failure.
  Future<void> loadOptions() async {
    final resp = await _vm.fetchOptions();
    final int? httpStatus = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        httpStatus != null &&
        httpStatus >= 200 &&
        httpStatus < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        final options = VendorOptionsModel.fromJson(data);
        if (options.tabs.isNotEmpty) _tabs = options.tabs;
        if (options.statuses.isNotEmpty) _statuses = options.statuses;
        if (options.sortFields.isNotEmpty) _sortFields = options.sortFields;
        if (options.actions.isNotEmpty) _actions = options.actions;
        if (options.counts.isNotEmpty) _counts = options.counts;
        _defaultSortBy = options.defaultSortBy;
        _defaultSortOrder = options.defaultSortOrder;
        notifyListeners();
      }
    } else {
      appLog(
        '⚠️ Vendor options fetch failed (status: $httpStatus); using fallbacks',
        name: 'VendorsListController',
      );
    }
  }

  Future<void> loadFirstPage({
    String? search,
    String? filter,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    _search = search;
    _filter = filter;
    _status = status;
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _page = 1;

    _isLoading = true;
    notifyListeners();

    final list = await _fetchPage(1);
    if (list != null) _vendors = list;

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
      _vendors = [..._vendors, ...list];
      _page = next;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> refresh() => loadFirstPage(
    search: _search,
    filter: _filter,
    status: _status,
    sortBy: _sortBy,
    sortOrder: _sortOrder,
  );

  // ── Export ──────────────────────────────────────────────────────────────────

  bool _isExporting = false;
  bool get isExporting => _isExporting;

  /// Returns an error message on failure, or null on success.
  Future<String?> exportVendors() async {
    _isExporting = true;
    notifyListeners();

    try {
      final response = await _vm.exportVendors();
      if (response == null ||
          response.statusCode < 200 ||
          response.statusCode >= 300) {
        appLog(
          '⚠️ Vendor export failed (status: ${response?.statusCode})',
          name: 'VendorsListController',
        );
        return 'Export failed. Please try again.';
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'vendors_$timestamp.csv';
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      final uri = Uri.file(file.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return null;
      } else {
        return 'File saved but could not be opened automatically.';
      }
    } catch (e, st) {
      appLog(
        '❌ Vendor export error: $e',
        name: 'VendorsListController',
        error: e,
        stackTrace: st,
      );
      return 'An unexpected error occurred during export.';
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<List<VendorModel>?> _fetchPage(int page) async {
    final resp = await _vm.fetchVendors(
      search: _search,
      filter: _filter,
      status: _status,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      page: page,
      pageSize: _pageSize,
    );

    final int? httpStatus = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        httpStatus != null &&
        httpStatus >= 200 &&
        httpStatus < 300) {
      _errorMessage = null;
      final data = resp['data'] as Map<String, dynamic>?;
      _totalCount = (data?['count'] as num?)?.toInt() ?? 0;
      _hasMore = data?['next'] != null;
      final raw = (data?['results'] as List<dynamic>?) ?? [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(VendorModel.fromJson)
          .toList();
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Could not load vendors. Please try again.')
              .toString();
      appLog(
        '⚠️ Vendors fetch failed (status: $httpStatus)',
        name: 'VendorsListController',
      );
      return null;
    }
  }
}
