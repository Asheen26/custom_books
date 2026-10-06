import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/invoices/models/invoice_comment_model.dart';
import 'package:custom_books/features/invoices/viewmodels/invoice_comments_viewmodel.dart';
import 'package:flutter/material.dart';

/// Manages loading and posting comments/history for a single invoice.
class InvoiceCommentsController extends ChangeNotifier {
  InvoiceCommentsController(this.invoiceId);

  final String invoiceId;
  final _vm = InvoiceCommentsViewModel();

  // ── state ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  List<InvoiceComment> _comments = [];
  List<InvoiceComment> get comments => List.unmodifiable(_comments);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── load ──────────────────────────────────────────────────────────────────
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final resp = await _vm.fetchComments(invoiceId);
    final int? status = resp?['_statusCode'] as int?;

    if (_isOk(resp, status)) {
      _errorMessage = null;
      _comments = _parseList(resp!['data']);
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Could not load comments. Please try again.')
              .toString();
      appLog(
        '⚠️ Invoice comments fetch failed (status: $status)',
        name: 'InvoiceCommentsController',
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── submit ────────────────────────────────────────────────────────────────
  /// Posts a new comment and refreshes the list on success.
  /// Returns true on success, false on failure.
  Future<bool> submit(String text) async {
    final comment = text.trim();
    if (comment.isEmpty || _isSubmitting) return false;

    _isSubmitting = true;
    notifyListeners();

    final resp = await _vm.addComment(invoiceId, comment);
    final int? status = resp?['_statusCode'] as int?;
    final ok = _isOk(resp, status);

    if (ok) {
      _errorMessage = null;
      await _reloadAfterSubmit();
    } else {
      _errorMessage =
          (resp?['message'] ?? 'Could not add comment. Please try again.')
              .toString();
      appLog(
        '⚠️ Add invoice comment failed (status: $status)',
        name: 'InvoiceCommentsController',
      );
    }

    _isSubmitting = false;
    notifyListeners();
    return ok;
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  Future<void> _reloadAfterSubmit() async {
    final resp = await _vm.fetchComments(invoiceId);
    final int? status = resp?['_statusCode'] as int?;
    if (_isOk(resp, status)) {
      _comments = _parseList(resp!['data']);
    }
  }

  bool _isOk(Map<String, dynamic>? resp, int? status) =>
      resp != null &&
      resp['success'] == true &&
      status != null &&
      status >= 200 &&
      status < 300;

  /// Handles both `data` as a bare List and `data` as `{results: [...]}`.
  List<InvoiceComment> _parseList(dynamic data) {
    List<dynamic> raw;
    if (data is List) {
      raw = data;
    } else if (data is Map<String, dynamic>) {
      raw = (data['results'] as List<dynamic>?) ?? const [];
    } else {
      raw = const [];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(InvoiceComment.fromJson)
        .toList();
  }
}
