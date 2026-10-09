import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/purchase_orders/models/purchase_order_model.dart';
import 'package:flutter/material.dart';

/// Summary header card shown at the top of [PurchaseOrderDetailsPage].
///
/// Displays: PO number, vendor name (tappable), status badge, Total Amount,
/// circular attachment button, Location, and Order Date.
class PoDetailsHeader extends StatelessWidget {
  final PurchaseOrderModel order;
  final VoidCallback onAttachmentTap;

  const PoDetailsHeader({
    super.key,
    required this.order,
    required this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = order.status.color;

    return Container(
      width: double.infinity,
      color: context.colors.card,
      padding: EdgeInsets.fromLTRB(
        Dimensions.width20,
        Dimensions.height15,
        Dimensions.width20,
        Dimensions.height15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── PO number + status badge ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.purchaseOrderNumber,
                      style: TextStyle(
                        fontSize: Dimensions.font20 * 1.05,
                        fontWeight: FontWeight.w900,
                        color: context.colors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10 / 3),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        order.vendorName,
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10 + 2,
                  vertical: Dimensions.height10 * 0.4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Dimensions.radius15 / 3),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.62,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height15),

          // ── Total amount + attachment button ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.72,
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10 / 3),
                    Text(
                      '₹${order.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: Dimensions.font20 * 1.15,
                        fontWeight: FontWeight.w900,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onAttachmentTap,
                child: Container(
                  width: Dimensions.height45 * 1.1,
                  height: Dimensions.height45 * 1.1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.border,
                      width: 1.5,
                    ),
                    color: context.colors.card,
                  ),
                  child: Icon(
                    Icons.attach_file_rounded,
                    size: Dimensions.iconSize24 - 2,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height15),
          Divider(height: 1, color: context.colors.border),
          SizedBox(height: Dimensions.height10),

          // ── Location + Order Date ──────────────────────────────────────
          _infoRow(context, 'Location:', 'warehouse1'),
          SizedBox(height: Dimensions.height10 / 2),
          _infoRow(context, 'Order Date:', formatDate(order.orderDate)),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.78,
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: Dimensions.width10 / 2),
        Text(
          value,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.82,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
