class DeliveryChallanOption {
  final String key;
  final String label;

  const DeliveryChallanOption({required this.key, required this.label});

  factory DeliveryChallanOption.fromJson(Map<String, dynamic> json) {
    return DeliveryChallanOption(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? json['key'] ?? '').toString(),
    );
  }
}

class DeliveryChallanOptionsModel {
  final List<DeliveryChallanOption> filters;
  final List<DeliveryChallanOption> sortFields;

  const DeliveryChallanOptionsModel({
    this.filters = const [],
    this.sortFields = const [],
  });

  bool get isEmpty => filters.isEmpty && sortFields.isEmpty;

  factory DeliveryChallanOptionsModel.fromJson(Map<String, dynamic> json) {
    return DeliveryChallanOptionsModel(
      filters: _parseList(json['filters']),
      sortFields: _parseList(json['sort_fields']),
    );
  }

  static List<DeliveryChallanOption> _parseList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(DeliveryChallanOption.fromJson)
        .where((o) => o.key.isNotEmpty)
        .toList();
  }
}
