import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/delivery_challans/models/delivery_challan_model.dart';
import 'package:custom_books/features/delivery_challans/models/delivery_challan_options_model.dart';
import 'package:custom_books/features/delivery_challans/viewmodels/delivery_challans_list_viewmodel.dart';
import 'package:flutter/material.dart';

class DeliveryChallansListController extends ChangeNotifier {
  final _vm = DeliveryChallansListViewModel();

  static const List<DeliveryChallanOption> _fallbackFilters = [
    DeliveryChallanOption(key: 'all', label: 'All'),
    DeliveryChallanOption(key: 'draft', label: 'Draft'),
    DeliveryChallanOption(key: 'delivered', label: 'Delivered'),
    DeliveryChallanOption(key: 'returned', label: 'Returned'),
    DeliveryChallanOption(key: 'cancelled', label: 'Cancelled'),
  ];

  static const List<DeliveryChallanOption> _fallbackSortFields = [
    DeliveryChallanOption(key: 'created_time', label: 'Created Time'),
    DeliveryChallanOption(key: 'date', label: 'Date'),
    DeliveryChallanOption(key: 'challan_number', label: 'Challan#'),
    DeliveryChallanOption(key: 'customer_name', label: 'Customer Name'),
    DeliveryChallanOption(key: 'total_amount', label: 'Amount'),
  ];

  List<DeliveryChallanOption> _filterOptions = _fallbackFilters;
  List<DeliveryChallanOption> get filterOptions =>
      List.unmodifiable(_filterOptions);

  List<DeliveryChallanOption> _sortFieldOptions = _fallbackSortFields;
  List<DeliveryChallanOption> get sortFieldOptions =>
      List.unmodifiable(_sortFieldOptions);

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
        final options = DeliveryChallanOptionsModel.fromJson(data);
        if (options.filters.isNotEmpty) _filterOptions = options.filters;
        if (options.sortFields.isNotEmpty) {
          _sortFieldOptions = options.sortFields;
        }
        notifyListeners();
      }
    } else {
      appLog(
        '⚠️ Challan options fetch failed (status: $status); using fallbacks',
        name: 'DeliveryChallansListController',
      );
    }
  }

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
