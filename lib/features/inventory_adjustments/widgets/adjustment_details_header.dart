import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/inventory_adjustments/models/inventory_adjustments_model.dart';
import 'package:flutter/material.dart';

/// Summary header card at the top of [AdjustmentDetailsPage].
///
/// Shows: date, status badge, reason, and an optional attachment badge.
class AdjustmentDetailsHeader extends StatelessWidget {
  final InventoryAdjustment adjustment;
  final int attachmentCount;
  final VoidCallback onAttachmentTap;

  const AdjustmentDetailsHeader({
    super.key,
    required this.adjustment,
    required this.attachmentCount,
    required this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDraft = adjustment.status == AdjustmentStatus.draft;
    final statusColor = isDraft ? AppColors.warn : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
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
        children: [
          // Date row + status chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.7,
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10 + 2,
                  vertical: Dimensions.height10 * 0.5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Dimensions.radius30),
                ),
                child: Text(
                  adjustment.status.label,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.62,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height10 / 2.5),
          Text(
            formatDate(adjustment.date),
            style: TextStyle(
              fontSize: Dimensions.font20 * 0.95,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: Dimensions.height20),

          // Reason + optional attachment button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reason',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.7,
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10 / 2.5),
                    Text(
                      adjustment.reason,
                      style: TextStyle(
                        fontSize: Dimensions.font20 * 0.95,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (attachmentCount > 0)
                GestureDetector(
                  onTap: onAttachmentTap,
                  child: Container(
                    padding: EdgeInsets.all(Dimensions.width10 + 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(Dimensions.radius15),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Badge(
                      label: Text(
                        '$attachmentCount',
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.56,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: AppColors.accent,
                      child: Icon(
                        Icons.attach_file_rounded,
                        color: AppColors.primary,
                        size: Dimensions.iconSize24 - 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
