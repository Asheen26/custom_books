import 'package:custom_books/core/enums/sort_direction.dart';
import 'package:custom_books/core/widgets/generic_sort_sheet.dart';
import 'package:custom_books/features/delivery_challans/models/delivery_challan_model.dart';
import 'package:flutter/material.dart';

class DeliveryChallanSortSheet extends StatelessWidget {
  final DeliveryChallanSortField selectedField;
  final SortDirection selectedDirection;
  final void Function(DeliveryChallanSortField field, SortDirection direction)
  onApply;

  const DeliveryChallanSortSheet({
    super.key,
    required this.selectedField,
    required this.selectedDirection,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return GenericSortSheet<DeliveryChallanSortField>(
      fields: DeliveryChallanSortField.values,
      initialField: selectedField,
      initialDirection: selectedDirection,
      labelBuilder: (f) => f.label,
      onApply: onApply,
    );
  }
}
