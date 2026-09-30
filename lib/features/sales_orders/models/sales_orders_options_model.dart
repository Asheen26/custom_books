/// Model for the response of GET /api/sales-orders/options/
class SalesOrdersOptionsModel {
  final List<SalesOrderTab> tabs;
  final List<SalesOrderOptionItem> statuses;
  final List<SalesOrderOptionItem> taxTypes;
  final List<SalesOrderOptionItem> sortFields;
  final SalesOrderDefaultSort defaultSort;
  final List<SalesOrderOptionItem> paymentTerms;
  final Map<String, int> counts;

  const SalesOrdersOptionsModel({
    required this.tabs,
    required this.statuses,
    required this.taxTypes,
    required this.sortFields,
    required this.defaultSort,
    required this.paymentTerms,
    required this.counts,
  });

  factory SalesOrdersOptionsModel.fromJson(Map<String, dynamic> json) {
    List<SalesOrderOptionItem> parseItems(dynamic raw) {
      if (raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(SalesOrderOptionItem.fromJson)
          .toList();
    }

    return SalesOrdersOptionsModel(
      tabs: (json['tabs'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(SalesOrderTab.fromJson)
          .toList(),
      statuses: parseItems(json['statuses']),
      taxTypes: parseItems(json['tax_types']),
      sortFields: parseItems(json['sort_fields']),
      defaultSort: json['default_sort'] != null
          ? SalesOrderDefaultSort.fromJson(
              json['default_sort'] as Map<String, dynamic>)
          : const SalesOrderDefaultSort(sortBy: 'created_time', sortOrder: 'desc'),
      paymentTerms: parseItems(json['payment_terms']),
      counts: {
        for (final e
            in (json['counts'] as Map<String, dynamic>? ?? {}).entries)
          e.key: (e.value as num?)?.toInt() ?? 0,
      },
    );
  }

  /// Total count shown in the app bar subtitle.
  int get totalCount => counts['all'] ?? 0;
}

class SalesOrderTab {
  final String key;
  final String label;

  const SalesOrderTab({required this.key, required this.label});

  factory SalesOrderTab.fromJson(Map<String, dynamic> json) => SalesOrderTab(
        key: (json['key'] ?? '').toString(),
        label: (json['label'] ?? '').toString(),
      );
}

class SalesOrderOptionItem {
  final String key;
  final String label;

  const SalesOrderOptionItem({required this.key, required this.label});

  factory SalesOrderOptionItem.fromJson(Map<String, dynamic> json) =>
      SalesOrderOptionItem(
        key: (json['key'] ?? '').toString(),
        label: (json['label'] ?? '').toString(),
      );
}

class SalesOrderDefaultSort {
  final String sortBy;
  final String sortOrder;

  const SalesOrderDefaultSort({
    required this.sortBy,
    required this.sortOrder,
  });

  factory SalesOrderDefaultSort.fromJson(Map<String, dynamic> json) =>
      SalesOrderDefaultSort(
        sortBy: (json['sort_by'] ?? 'created_time').toString(),
        sortOrder: (json['sort_order'] ?? 'desc').toString(),
      );
}
