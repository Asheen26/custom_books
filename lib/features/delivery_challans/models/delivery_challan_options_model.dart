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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryChallanOption &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
}

class DeliveryChallanDefaultSort {
  final String sortBy;
  final String sortOrder;

  const DeliveryChallanDefaultSort({
    this.sortBy = 'created_time',
    this.sortOrder = 'desc',
  });

  factory DeliveryChallanDefaultSort.fromJson(Map<String, dynamic> json) {
    return DeliveryChallanDefaultSort(
      sortBy: (json['sort_by'] ?? 'created_time').toString(),
      sortOrder: (json['sort_order'] ?? 'desc').toString(),
    );
  }
}

class DeliveryChallanOptionsModel {
  final List<DeliveryChallanOption> tabs;
  final List<DeliveryChallanOption> statuses;
  final List<DeliveryChallanOption> challanTypes;
  final List<DeliveryChallanOption> sortFields;
  final DeliveryChallanDefaultSort defaultSort;
  final Map<String, int> counts;

  const DeliveryChallanOptionsModel({
    this.tabs = const [],
    this.statuses = const [],
    this.challanTypes = const [],
    this.sortFields = const [],
    this.defaultSort = const DeliveryChallanDefaultSort(),
    this.counts = const {},
  });

  bool get isEmpty =>
      tabs.isEmpty &&
      statuses.isEmpty &&
      challanTypes.isEmpty &&
      sortFields.isEmpty;

  factory DeliveryChallanOptionsModel.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseCounts(dynamic value) {
      if (value is! Map) return const {};
      return Map.fromEntries(
        value.entries
            .where((e) => e.value is num)
            .map((e) => MapEntry(e.key.toString(), (e.value as num).toInt())),
      );
    }

    final defaultSortJson = json['default_sort'];
    return DeliveryChallanOptionsModel(
      tabs: _parseList(json['tabs']),
      statuses: _parseList(json['statuses']),
      challanTypes: _parseList(json['challan_types']),
      sortFields: _parseList(json['sort_fields']),
      defaultSort: defaultSortJson is Map<String, dynamic>
          ? DeliveryChallanDefaultSort.fromJson(defaultSortJson)
          : const DeliveryChallanDefaultSort(),
      counts: parseCounts(json['counts']),
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
