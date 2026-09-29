class CustomerOption {
  final String key;
  final String label;

  const CustomerOption({required this.key, required this.label});

  factory CustomerOption.fromJson(Map<String, dynamic> json) {
    return CustomerOption(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? json['key'] ?? '').toString(),
    );
  }
}

class CustomerOptionsModel {
  final List<CustomerOption> filters;
  final List<CustomerOption> sortFields;

  const CustomerOptionsModel({
    this.filters = const [],
    this.sortFields = const [],
  });

  bool get isEmpty => filters.isEmpty && sortFields.isEmpty;

  factory CustomerOptionsModel.fromJson(Map<String, dynamic> json) {
    return CustomerOptionsModel(
      filters: _parseList(json['filters']),
      sortFields: _parseList(json['sort_fields']),
    );
  }

  static List<CustomerOption> _parseList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(CustomerOption.fromJson)
        .where((o) => o.key.isNotEmpty)
        .toList();
  }
}
