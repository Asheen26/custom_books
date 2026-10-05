import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/delivery_challans/models/delivery_challan_model.dart';
import 'package:custom_books/features/delivery_challans/models/delivery_challan_options_model.dart';
import 'package:custom_books/features/delivery_challans/viewmodels/delivery_challans_list_viewmodel.dart';
import 'package:flutter/material.dart';

class DeliveryChallansListController extends ChangeNotifier {
  final _vm = DeliveryChallansListViewModel();

  // ── Fallbacks (used until the options API responds) ──────────────────────

  static const List<DeliveryChallanOption> _fallbackTabs = [
    DeliveryChallanOption(key: 'all', label: 'All'),
    DeliveryChallanOption(key: 'draft', label: 'Draft'),
    DeliveryChallanOption(key: 'delivered', label: 'Delivered'),
  ];

  static const List<DeliveryChallanOption> _fallbackStatuses = [
    DeliveryChallanOption(key: 'all_statuses', label: 'All Statuses'),
    DeliveryChallanOption(key: 'draft', label: 'DRAFT'),
    DeliveryChallanOption(key: 'delivered', label: 'DELIVERED'),
    DeliveryChallanOption(key: 'returned', label: 'RETURNED'),
    DeliveryChallanOption(key: 'cancelled', label: 'CANCELLED'),
  ];

  static const List<DeliveryChallanOption> _fallbackChallanTypes = [
    DeliveryChallanOption(key: 'job_work', label: 'Job Work'),
    DeliveryChallanOption(
      key: 'supply_on_approval',
      label: 'Supply on Approval',
    ),
    DeliveryChallanOption(
      key: 'supply_of_liquid_gas',
      label: 'Supply of Liquid Gas',
    ),
    DeliveryChallanOption(key: 'others', label: 'Others'),
  ];

  static const List<DeliveryChallanOption> _fallbackSortFields = [
    DeliveryChallanOption(key: 'created_time', label: 'Created Time'),
    DeliveryChallanOption(key: 'date', label: 'Date'),
    DeliveryChallanOption(key: 'challan_number', label: 'Challan#'),
    DeliveryChallanOption(key: 'customer_name', label: 'Customer Name'),
    DeliveryChallanOption(key: 'amount', label: 'Amount'),
  ];

  // ── Live option lists ────────────────────────────────────────────────────

  List<DeliveryChallanOption> _tabs = _fallbackTabs;
  List<DeliveryChallanOption> get tabs => List.unmodifiable(_tabs);

  List<DeliveryChallanOption> _statuses = _fallbackStatuses;
  List<DeliveryChallanOption> get statuses => List.unmodifiable(_statuses);

  List<DeliveryChallanOption> _challanTypes = _fallbackChallanTypes;
  List<DeliveryChallanOption> get challanTypes =>
      List.unmodifiable(_challanTypes);

  List<DeliveryChallanOption> _sortFields = _fallbackSortFields;
  List<DeliveryChallanOption> get sortFields => List.unmodifiable(_sortFields);

  DeliveryChallanDefaultSort _defaultSort = const DeliveryChallanDefaultSort();
  DeliveryChallanDefaultSort get defaultSort => _defaultSort;

  Map<String, int> _counts = const {};
  Map<String, int> get counts => Map.unmodifiable(_counts);

  int countForTab(String tabKey) => _counts[tabKey] ?? 0;

  // ── Options fetch ────────────────────────────────────────────────────────

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
        final options = DeliveryChallanOptionsModel.fromJson(data);
        if (options.tabs.isNotEmpty) _tabs = options.tabs;
        if (options.statuses.isNotEmpty) _statuses = options.statuses;
        if (options.challanTypes.isNotEmpty) {
          _challanTypes = options.challanTypes;
        }
        if (options.sortFields.isNotEmpty) _sortFields = options.sortFields;
        _defaultSort = options.defaultSort;
        _counts = options.counts;
        notifyListeners();
      }
    } else {
      appLog(
        '⚠️ Challan options fetch failed (status: $status); using fallbacks',
        name: 'DeliveryChallansListController',
      );
    }
  }

  // ── List fetch ───────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<DeliveryChallanModel> _challans = [];
  List<DeliveryChallanModel> get challans => List.unmodifiable(_challans);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> load({
    String? status,
    String? sortBy,
    String? sortOrder,
    String? search,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await _fetch(
      status: status,
      sortBy: sortBy,
      sortOrder: sortOrder,
      search: search,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetch({
    String? status,
    String? sortBy,
    String? sortOrder,
    String? search,
  }) async {
    final resp = await _vm.fetchChallans(
      status: status,
      sortBy: sortBy,
      sortOrder: sortOrder,
      search: search,
    );
    final int? statusCode = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      _errorMessage = null;
      final data = resp['data'] as Map<String, dynamic>?;
      final raw = (data?['results'] as List<dynamic>?) ?? [];
      _challans = raw
          .whereType<Map<String, dynamic>>()
          .map(DeliveryChallanModel.fromJson)
          .toList();
    } else {
      _errorMessage =
          (resp?['message'] ??
                  'Could not load delivery challans. Please try again.')
              .toString();
      appLog(
        '⚠️ Delivery challans fetch failed (status: $statusCode)',
        name: 'DeliveryChallansListController',
      );
    }
  }

  void addChallan(DeliveryChallanModel challan) {
    _challans = [challan, ..._challans];
    notifyListeners();
  }
}
