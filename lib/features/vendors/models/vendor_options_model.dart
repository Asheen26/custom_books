/// A single key/label pair used for tabs, statuses, sort fields, and actions.
class VendorOption {
  final String key;
  final String label;

  const VendorOption({required this.key, required this.label});

  factory VendorOption.fromJson(Map<String, dynamic> json) {
    return VendorOption(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? json['key'] ?? '').toString(),
    );
  }
}

/// A single action entry from the options endpoint (e.g. save, import, export).
class VendorAction {
  final String key;
  final String label;
  final String path;

  const VendorAction({
    required this.key,
    required this.label,
    required this.path,
  });

  factory VendorAction.fromJson(Map<String, dynamic> json) {
    return VendorAction(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      path: (json['path'] ?? '').toString(),
    );
  }
}

/// Deserialized shape of `GET /api/vendors/options/` → `data`.
class VendorOptionsModel {
  /// Tab definitions: All / Active / Inactive
  final List<VendorOption> tabs;

  /// Filter-sheet status options: all_vendors / active / inactive
  final List<VendorOption> statuses;

  /// Sort-sheet field options: created_time / name / company_name / payables
  final List<VendorOption> sortFields;

  /// Default sort from the server (sort_by + sort_order).
  final String defaultSortBy;
  final String defaultSortOrder;

  /// Per-tab record counts returned alongside the options.
  final Map<String, int> counts;

  /// Actions for the details page popup menu.
  final List<VendorAction> actions;

  const VendorOptionsModel({
    this.tabs = const [],
    this.statuses = const [],
    this.sortFields = const [],
    this.defaultSortBy = 'created_time',
    this.defaultSortOrder = 'desc',
    this.counts = const {},
    this.actions = const [],
  });

  bool get isEmpty =>
      tabs.isEmpty && statuses.isEmpty && sortFields.isEmpty;

  factory VendorOptionsModel.fromJson(Map<String, dynamic> json) {
    final defaultSort = json['default_sort'] as Map<String, dynamic>? ?? {};
    final rawCounts = json['counts'] as Map<String, dynamic>? ?? {};

    return VendorOptionsModel(
      tabs: _parseOptions(json['tabs']),
      statuses: _parseOptions(json['statuses']),
      sortFields: _parseOptions(json['sort_fields']),
      defaultSortBy: (defaultSort['sort_by'] ?? 'created_time').toString(),
      defaultSortOrder: (defaultSort['sort_order'] ?? 'desc').toString(),
      counts: rawCounts.map(
        (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
      ),
      actions: _parseActions(json['actions']),
    );
  }

  static List<VendorOption> _parseOptions(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(VendorOption.fromJson)
        .where((o) => o.key.isNotEmpty)
        .toList();
  }

  static List<VendorAction> _parseActions(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(VendorAction.fromJson)
        .where((a) => a.key.isNotEmpty)
        .toList();
  }
}
