import 'dart:io';

import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/payments_received/models/payment_received_model.dart';
import 'package:custom_books/features/payments_received/models/payments_received_options_model.dart';
import 'package:custom_books/features/payments_received/viewmodels/payments_received_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Manages the payments-received list state: options, pagination, search, and errors.
class PaymentsReceivedListController extends ChangeNotifier {
  final _vm = PaymentsReceivedListViewModel();

  static const int _pageSize = 20;

  // ── fallback options (used until server responds) ─────────────────────────

  static const List<PaymentReceivedOption> _fallbackTabs = [
    PaymentReceivedOption(key: 'all', label: 'All'),
    PaymentReceivedOption(key: 'this_month', label: 'This Month'),
    PaymentReceivedOption(key: 'unapplied', label: 'Unapplied'),
  ];

  static const List<PaymentReceivedOption> _fallbackModes = [
    PaymentReceivedOption(key: 'all_modes', label: 'All Modes'),
    PaymentReceivedOption(key: 'cash', label: 'Cash'),
    PaymentReceivedOption(key: 'bank_transfer', label: 'Bank Transfer'),
    PaymentReceivedOption(key: 'card', label: 'Card'),
    PaymentReceivedOption(key: 'cheque', label: 'Cheque'),
    PaymentReceivedOption(key: 'upi', label: 'UPI'),
  ];

  static const List<PaymentReceivedOption> _fallbackStatuses = [
    PaymentReceivedOption(key: 'all_statuses', label: 'All Statuses'),
    PaymentReceivedOption(key: 'unapplied', label: 'Unapplied'),
    PaymentReceivedOption(key: 'applied', label: 'Applied'),
    PaymentReceivedOption(key: 'void', label: 'Void'),
  ];

  static const List<PaymentReceivedOption> _fallbackSortFields = [
    PaymentReceivedOption(key: 'created_time', label: 'Created Time'),
    PaymentReceivedOption(key: 'date', label: 'Date'),
    PaymentReceivedOption(key: 'payment_number', label: 'Payment#'),
    PaymentReceivedOption(key: 'customer_name', label: 'Customer Name'),
    PaymentReceivedOption(key: 'amount', label: 'Amount'),
  ];

  // ── options state ─────────────────────────────────────────────────────────

  List<PaymentReceivedOption> _tabOptions = _fallbackTabs;
  List<PaymentReceivedOption> _modeOptions = _fallbackModes;
  List<PaymentReceivedOption> _statusOptions = _fallbackStatuses;
  List<PaymentReceivedOption> _sortFieldOptions = _fallbackSortFields;
  List<PaymentReceivedAction> _actions = const [];
  Map<String, int> _counts = const {};

  List<PaymentReceivedOption> get tabOptions => List.unmodifiable(_tabOptions);
  List<PaymentReceivedOption> get modeOptions =>
      List.unmodifiable(_modeOptions);
  List<PaymentReceivedOption> get statusOptions =>
      List.unmodifiable(_statusOptions);
  List<PaymentReceivedOption> get sortFieldOptions =>
      List.unmodifiable(_sortFieldOptions);
  List<PaymentReceivedAction> get actions => List.unmodifiable(_actions);
  Map<String, int> get counts => Map.unmodifiable(_counts);

  List<String> get tabLabels =>
      _tabOptions.map((o) => o.label).toList(growable: false);
  List<String> get modeLabels =>
      _modeOptions.map((o) => o.label).toList(growable: false);
  List<String> get statusLabels =>
      _statusOptions.map((o) => o.label).toList(growable: false);
  List<String> get sortFieldLabels =>
      _sortFieldOptions.map((o) => o.label).toList(growable: false);

  String? tabKeyForIndex(int index) {
    if (index < 0 || index >= _tabOptions.length) return null;
    return _tabOptions[index].key;
  }

  String? modeKeyForLabel(String label) {
    for (final o in _modeOptions) {
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

  int countForTabKey(String key) => _counts[key] ?? 0;

  // ── loading states ────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // ── data ──────────────────────────────────────────────────────────────────

  List<PaymentReceivedModel> _payments = [];
  List<PaymentReceivedModel> get payments => List.unmodifiable(_payments);

  int _totalCount = 0;
  int get totalCount => _totalCount;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── pagination state ─────────────────────────────────────────────────────

  int _page = 1;

  // ── current query params ─────────────────────────────────────────────────

  String? _search;
  String? _sortBy;
  String? _sortOrder;
  String? _tab;
  String? _mode;
  String? _status;

  // ── options ───────────────────────────────────────────────────────────────

  /// Fetches tabs, modes, statuses, sort fields, and counts from the API.
  /// Falls back to hardcoded values if the request fails.
  Future<void> loadOptions() async {
    final resp = await _vm.fetchOptions();
    final int? statusCode = resp?['_statusCode'] as int?;

    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        final opts = PaymentsReceivedOptionsModel.fromJson(data);
        if (opts.tabs.isNotEmpty) _tabOptions = opts.tabs;
        if (opts.modes.isNotEmpty) _modeOptions = opts.modes;
        if (opts.statuses.isNotEmpty) _statusOptions = opts.statuses;
        if (opts.sortFields.isNotEmpty) _sortFieldOptions = opts.sortFields;
        if (opts.actions.isNotEmpty) _actions = opts.actions;
        if (opts.counts.isNotEmpty) _counts = opts.counts;
        notifyListeners();
      }
    } else {
      appLog(
        '⚠️ Payments received options fetch failed (status: $statusCode); using fallbacks',
        name: 'PaymentsReceivedListController',
      );
    }
  }

  // ── pagination ────────────────────────────────────────────────────────────

  /// Resets to page 1 and reloads. Call whenever filters / sort / search change.
  Future<void> loadFirstPage({
    String? search,
    String? sortBy,
    String? sortOrder,
    String? tab,
    String? mode,
    String? status,
  }) async {
    _search = search;
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _tab = tab;
    _mode = mode;
    _status = status;
    _page = 1;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final list = await _fetchPage(1);
    if (list != null) {
      _payments = list;
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
      _payments = [..._payments, ...list];
      _page = next;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Inserts a freshly created payment at the top of the list without a
  /// network round-trip (optimistic update after POST succeeds).
  void prependPayment(PaymentReceivedModel payment) {
    _payments = [payment, ..._payments];
    _totalCount += 1;
    notifyListeners();
  }

  Future<List<PaymentReceivedModel>?> _fetchPage(int page) async {
    final resp = await _vm.fetchPayments(
      search: _search,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      tab: _tab,
      mode: _mode,
      status: _status,
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
          .map(PaymentReceivedModel.fromJson)
          .toList();
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Could not load payments. Please try again.')
              .toString();
      appLog(
        '⚠️ Payments received fetch failed (status: $statusCode)',
        name: 'PaymentsReceivedListController',
      );
      return null;
    }
  }

  // ── Export ────────────────────────────────────────────────────────────────

  bool _isExporting = false;
  bool get isExporting => _isExporting;

  /// Calls `GET /api/payments-received/export/?export_format=<format>`,
  /// writes the bytes to a temp file, and opens it via [url_launcher].
  ///
  /// [format] should be `'csv'` or `'json'`.
  /// Returns `null` on success, or an error message on failure.
  Future<String?> exportPayments({String format = 'csv'}) async {
    _isExporting = true;
    notifyListeners();

    try {
      final response = await _vm.exportPayments(format: format);
      if (response == null ||
          response.statusCode < 200 ||
          response.statusCode >= 300) {
        appLog(
          '⚠️ Export failed (status: ${response?.statusCode})',
          name: 'PaymentsReceivedListController',
        );
        return 'Export failed. Please try again.';
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'payments_received_$timestamp.$format';
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      final uri = Uri.file(file.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return null;
      } else {
        appLog(
          '⚠️ Could not open exported file: ${file.path}',
          name: 'PaymentsReceivedListController',
        );
        return 'File saved but could not be opened automatically.';
      }
    } catch (e, st) {
      appLog(
        '❌ Export error: $e',
        name: 'PaymentsReceivedListController',
        error: e,
        stackTrace: st,
      );
      return 'Export failed: $e';
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }
}
