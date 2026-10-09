import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/items/models/item_model.dart';
import 'package:flutter/material.dart';

/// HISTORY tab for [ItemDetailsPage].
/// Shows a timeline of creation and update events.
class ItemHistoryTab extends StatelessWidget {
  final ItemModel item;
  const ItemHistoryTab({super.key, required this.item});

  List<_Event> get _events {
    final created = item.createdAt ?? DateTime(2026, 6, 3, 17, 27);
    final updated = item.updatedAt ?? DateTime(2026, 6, 10, 19, 16);
    return [
      _Event(action: 'created by', by: 'Parthiv p', at: created),
      _Event(action: 'updated by', by: 'Parthiv p', at: created.add(const Duration(hours: 2, minutes: 17))),
      _Event(action: 'updated by', by: 'Parthiv p', at: updated),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final events = _events;
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height20),
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (_, i) => _tile(context, events[i], isFirst: i == 0, isLast: i == events.length - 1),
    );
  }

  Widget _tile(BuildContext context, _Event event, {required bool isFirst, required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: Dimensions.iconSize16,
                height: Dimensions.iconSize16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.card,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : context.colors.border,
                ),
              ),
            ],
          ),
          SizedBox(width: Dimensions.width15),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: Dimensions.height30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.action, style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                  SizedBox(height: Dimensions.height10 / 3),
                  Row(
                    children: [
                      Text(event.by, style: TextStyle(fontSize: Dimensions.font16 * 0.8, color: context.colors.textSecondary)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.width10),
                        child: Text('|', style: TextStyle(color: context.colors.textTertiary)),
                      ),
                      Text(formatDateTime(event.at), style: TextStyle(fontSize: Dimensions.font16 * 0.8, color: context.colors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Event {
  final String action, by;
  final DateTime at;
  const _Event({required this.action, required this.by, required this.at});
}
