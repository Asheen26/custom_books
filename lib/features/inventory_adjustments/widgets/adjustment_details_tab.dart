import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/features/inventory_adjustments/models/inventory_adjustments_model.dart';
import 'package:flutter/material.dart';

/// DETAILS tab for [AdjustmentDetailsPage].
///
/// Shows account/reference/creator/type card and the adjusted items list.
class AdjustmentDetailsTab extends StatelessWidget {
  final InventoryAdjustment adjustment;

  const AdjustmentDetailsTab({super.key, required this.adjustment});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        // ── Account & Details ──────────────────────────────────────────
        _card(context, [
          DetailRow(
            label: 'Account:',
            value: adjustment.account?.isNotEmpty == true
                ? adjustment.account!
                : '-',
          ),
          SizedBox(height: Dimensions.height15),
          DetailRow(
            label: 'Reference#:',
            value: adjustment.referenceNumber?.isNotEmpty == true
                ? adjustment.referenceNumber!
                : '-',
          ),
          SizedBox(height: Dimensions.height15),
          DetailRow(
            label: 'Adjusted By:',
            value: adjustment.createdBy.isNotEmpty ? adjustment.createdBy : '-',
          ),
          SizedBox(height: Dimensions.height15),
          DetailRow(
            label: 'Adjustment Type:',
            value: _typeLabel(adjustment.adjustmentType),
          ),
        ]),
        SizedBox(height: Dimensions.height15),

        // ── Adjusted Items ─────────────────────────────────────────────
        _card(context, [
          Text(
            'Adjusted Items',
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.95,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: Dimensions.height15),
          if (adjustment.lines.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
              child: Text(
                'No items in this adjustment.',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.8,
                  color: context.colors.textSecondary,
                ),
              ),
            )
          else
            ...adjustment.lines.map((item) => _lineItemCard(context, item)),
        ]),
        SizedBox(height: Dimensions.height15),

        // ── Description ────────────────────────────────────────────────
        _card(context, [
          Text(
            'More Information',
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.95,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: Dimensions.height15),
          Text(
            'Description',
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.72,
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Dimensions.height10 / 2),
          Text(
            adjustment.description?.isNotEmpty == true
                ? adjustment.description!
                : 'No description provided.',
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.88,
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
        SizedBox(height: Dimensions.height30),
      ],
    );
  }

  Widget _lineItemCard(BuildContext context, AdjustmentLine item) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height10),
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: Dimensions.height45,
            height: Dimensions.height45,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: AppColors.primary,
              size: Dimensions.iconSize24 - 2,
            ),
          ),
          SizedBox(width: Dimensions.width15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.9,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                if (item.sku?.isNotEmpty == true)
                  Text(
                    'SKU: ${item.sku}',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.72,
                      color: context.colors.textSecondary,
                    ),
                  ),
                Text(
                  'Rate: ₹${item.rate.toStringAsFixed(2)}  •  Value: ₹${item.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.7,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width15,
              vertical: Dimensions.height10 / 1.5,
            ),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              '${item.quantityAdjusted > 0 ? '+' : ''}${item.quantityAdjusted.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.85,
                fontWeight: FontWeight.w800,
                color: item.quantityAdjusted < 0
                    ? AppColors.warn
                    : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  String _typeLabel(String? type) {
    switch (type?.toLowerCase()) {
      case 'quantity':
        return 'Quantity';
      case 'value':
        return 'Value';
      default:
        return (type == null || type.isEmpty) ? '-' : type;
    }
  }
}
