import 'package:custom_books/core/enums/sort_direction.dart';
import 'package:custom_books/core/widgets/generic_sort_sheet.dart';
import 'package:flutter/material.dart';

class CustomerSortSheet extends StatelessWidget {
  final String selectedField;
  final bool ascending;
  final void Function(String field, bool ascending) onApply;

  final List<String> fields;

  const CustomerSortSheet({
    super.key,
    required this.selectedField,
    required this.ascending,
    required this.onApply,
    this.fields = defaultFields,
  });

  static const List<String> defaultFields = [
    'Name',
    'Receivables',
    'Unused Credits',
  ];

  @override
  Widget build(BuildContext context) {
    return GenericSortSheet<String>(
      fields: fields,
      initialField: selectedField,
      initialDirection: ascending
          ? SortDirection.ascending
          : SortDirection.descending,
      labelBuilder: (field) => field,
      onApply: (field, direction) =>
          onApply(field, direction == SortDirection.ascending),
    );
  }
}
