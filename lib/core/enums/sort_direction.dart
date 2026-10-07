enum SortDirection { ascending, descending }

extension SortDirectionApi on SortDirection {
  /// Value expected by the API's `sort_order` query parameter.
  String get apiValue => this == SortDirection.ascending ? 'asc' : 'desc';
}
