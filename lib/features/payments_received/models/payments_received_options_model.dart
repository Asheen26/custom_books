/// Generic key/label pair returned by the options API.
class PaymentReceivedOption {
  final String key;
  final String label;

  const PaymentReceivedOption({required this.key, required this.label});

  factory PaymentReceivedOption.fromJson(Map<String, dynamic> json) {
    return PaymentReceivedOption(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? json['key'] ?? '').toString(),
    );
  }
}

/// An action item from the options API.
class PaymentReceivedAction {
  final String key;
  final String label;
  final String path;

  const PaymentReceivedAction({
    required this.key,
    required this.label,
    required this.path,
  });

  factory PaymentReceivedAction.fromJson(Map<String, dynamic> json) {
    return PaymentReceivedAction(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? json['key'] ?? '').toString(),
      path: (json['path'] ?? '').toString(),
    );
  }
}

/// Parsed shape of GET /api/payments-received/options/
class PaymentsReceivedOptionsModel {
  final List<PaymentReceivedOption> tabs;
  final List<PaymentReceivedOption> modes;
  final List<PaymentReceivedOption> statuses;
  final List<PaymentReceivedOption> sortFields;
  final List<PaymentReceivedAction> actions;
  final String defaultSortBy;
  final String defaultSortOrder;
  final Map<String, int> counts;

  const PaymentsReceivedOptionsModel({
    this.tabs = const [],
    this.modes = const [],
    this.statuses = const [],
    this.sortFields = const [],
    this.actions = const [],
    this.defaultSortBy = 'created_time',
    this.defaultSortOrder = 'desc',
    this.counts = const {},
  });

  bool get isEmpty => tabs.isEmpty && modes.isEmpty && sortFields.isEmpty;

  factory PaymentsReceivedOptionsModel.fromJson(Map<String, dynamic> json) {
    final defaultSort =
        json['default_sort'] as Map<String, dynamic>? ?? const {};
    final countsRaw = json['counts'] as Map<String, dynamic>? ?? const {};
    final actionsRaw = json['actions'] as List<dynamic>? ?? const [];

    return PaymentsReceivedOptionsModel(
      tabs: _parseList(json['tabs']),
      modes: _parseList(json['modes']),
      statuses: _parseList(json['statuses']),
      sortFields: _parseList(json['sort_fields']),
      actions: actionsRaw
          .whereType<Map<String, dynamic>>()
          .map(PaymentReceivedAction.fromJson)
          .where((a) => a.key.isNotEmpty)
          .toList(),
      defaultSortBy: (defaultSort['sort_by'] ?? 'created_time').toString(),
      defaultSortOrder: (defaultSort['sort_order'] ?? 'desc').toString(),
      counts: countsRaw.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
    );
  }

  static List<PaymentReceivedOption> _parseList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(PaymentReceivedOption.fromJson)
        .where((o) => o.key.isNotEmpty)
        .toList();
  }
}
