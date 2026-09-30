import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/quotes/models/quote_model.dart';
import 'package:custom_books/features/quotes/viewmodels/quotes_list_viewmodel.dart';
import 'package:flutter/material.dart';

class QuotesListController extends ChangeNotifier {
  final _vm = QuotesListViewModel();

  static const int _pageSize = 20;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  List<QuoteModel> _quotes = [];
  List<QuoteModel> get quotes => List.unmodifiable(_quotes);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  int _page = 1;
  bool _hasMore = false;
  bool get hasMore => _hasMore;

  String? _statusFilter;
  String? _filter;
  String? _search;

  Future<void> loadFirstPage({
    String? status,
    String? filter,
    String? search,
  }) async {
    _statusFilter = status;
    _filter = filter;
    _search = search;
    _page = 1;

    _isLoading = true;
    notifyListeners();

    final list = await _fetchPage(1);
    if (list != null) _quotes = list;

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
      _quotes = [..._quotes, ...list];
      _page = next;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<List<QuoteModel>?> _fetchPage(int page) async {
    final resp = await _vm.fetchQuotes(
      status: _statusFilter,
      filter: _filter,
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
          .map(QuoteModel.fromJson)
          .toList();
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Could not load quotes. Please try again.')
              .toString();
      appLog(
        '⚠️ Quotes fetch failed (status: $statusCode)',
        name: 'QuotesListController',
      );
      return null;
    }
  }
}
