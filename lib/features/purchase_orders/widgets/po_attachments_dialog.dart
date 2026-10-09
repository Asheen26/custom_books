import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/features/purchase_orders/models/purchase_order_model.dart';
import 'package:flutter/material.dart';

/// Modal dialog shown when the user taps the attachment button on the
/// [PurchaseOrderDetailsPage] header.
class PoAttachmentsDialog extends StatelessWidget {
  final PurchaseOrderModel order;

  const PoAttachmentsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radius20),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimensions.width20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attachments',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 1.05,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: context.colors.textSecondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),

            // ── Info ─────────────────────────────────────────────────────
            Text(
              'You can add up to 10 attachments, each not exceeding 10 MB.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.85,
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: Dimensions.height20),

            // ── Add button ───────────────────────────────────────────────
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                ToastificationHelper.showInfo(
                  context,
                  'Add Attachment coming soon.',
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.colors.border, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radius30),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20 * 1.5,
                  vertical: Dimensions.height15,
                ),
              ),
              child: Text(
                'Add Attachment',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.88,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: Dimensions.height10),
          ],
        ),
      ),
    );
  }
}
