import 'package:custom_books/core/line_item/item_lookup_model.dart';
import 'package:custom_books/core/line_item/item_lookup_viewmodel.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/items/models/item_model.dart';
import 'package:flutter/material.dart';

/// Searches the items catalog (`GET /api/items/?search=`) and exposes the
/// results as [ItemLookupResult]s for the Add Line Item picker.
class ItemLookupController extends ChangeNotifier {
  final _vm = ItemLookupViewModel();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ItemLookupResult> _results = [];
  List<ItemLookupResult> get results => List.unmodifiable(_results);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      _results = [];
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final resp = await _vm.searchItems(q);
    final int? status = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        status != null &&
        status >= 200 &&
        status < 300) {
      _errorMessage = null;
      final data = resp['data'] as Map<String, dynamic>?;
      final raw = (data?['results'] as List<dynamic>?) ?? [];
      _results = raw.whereType<Map<String, dynamic>>().map(_toLookup).toList();
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Could not search items. Please try again.')
              .toString();
      appLog(
        '⚠️ Item search failed (status: $status)',
        name: 'ItemLookupController',
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _results = [];
    _errorMessage = null;
    notifyListeners();
  }

  ItemLookupResult _toLookup(Map<String, dynamic> json) {
    final item = ItemModel.fromJson(json);
    final stock = _toDouble(
      json['stock_on_hand'] ?? json['stock'] ?? item.openingStock,
    );
    return ItemLookupResult(
      id: item.id,
      name: item.name,
      stockOnHand: stock,
      imageUrl: item.imageUrl,
      costPrice: item.purchasePrice,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
