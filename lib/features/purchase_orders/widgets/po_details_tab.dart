import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/line_item_form_widgets.dart';
import 'package:custom_books/features/purchase_orders/models/purchase_order_model.dart';
import 'package:flutter/material.dart';

/// DETAILS tab content for [PurchaseOrderDetailsPage].
///
/// Shows: Deliver To address, Items table (with thumbnails, totals),
/// Template row, and optional Reference / Delivery Date / Notes / Terms cards.
class PoDetailsTab extends StatelessWidget {
  final PurchaseOrderModel order;

  const PoDetailsTab({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final subTotal = order.lineItems.fold<double>(0, (s, i) => s + i.net);
    final total = order.lineItems.fold<double>(
      0,
      (s, i) => s + i.net + i.taxAmount,
    );

    return ListView(
      padding: EdgeInsets.all(Dimensions.width15),
      physics: const BouncingScrollPhysics(),
      children: [
        // ── Deliver To ──────────────────────────────────────────────────
        _card(
          context,
          children: [
            _label(context, 'Deliver To'),
            SizedBox(height: Dimensions.height10),
            Text(
              'Demo Address, Demo Address\nKerala\nIndia',
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.88,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
                height: 1.55,
              ),
            ),
          ],
        ),
        SizedBox(height: Dimensions.height15),

        // ── Items table ─────────────────────────────────────────────────
        _card(
          context,
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.78,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.78,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.colors.border),

            if (order.lineItems.isEmpty)
              Padding(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Center(
                  child: Text(
                    'No items added',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.85,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ),
              )
            else
              ...order.lineItems.map((item) => _lineItemRow(context, item)),

            Divider(height: 1, color: context.colors.border),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height15,
              ),
              child: Column(
                children: [
                  _totalsRow(context, 'Sub Total', subTotal),
                  SizedBox(height: Dimensions.height10),
                  _totalsRow(context, 'Total', total, bold: true),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: Dimensions.height15),

        // ── Template ────────────────────────────────────────────────────
        _card(
          context,
          children: [
            _label(context, 'Template'),
            SizedBox(height: Dimensions.height10 / 2),
            Row(
              children: [
                Text(
                  "'Standard Template'",
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.88,
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  ' - ',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.88,
                    color: context.colors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => ToastificationHelper.showInfo(
                    context,
                    'Change Template coming soon.',
                  ),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.88,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // ── Optional extra fields ────────────────────────────────────────
        if (order.referenceNumber.isNotEmpty ||
            order.expectedDeliveryDate != null ||
            order.customerNotes.isNotEmpty ||
            order.termsAndConditions.isNotEmpty) ...[
          SizedBox(height: Dimensions.height15),
          _card(
            context,
            children: [
              if (order.referenceNumber.isNotEmpty) ...[
                _label(context, 'Reference#'),
                SizedBox(height: Dimensions.height10 / 2),
                _value(context, order.referenceNumber),
                SizedBox(height: Dimensions.height15),
              ],
              if (order.expectedDeliveryDate != null) ...[
                _label(context, 'Expected Delivery Date'),
                SizedBox(height: Dimensions.height10 / 2),
                _value(context, formatDate(order.expectedDeliveryDate!)),
                SizedBox(height: Dimensions.height15),
              ],
              if (order.customerNotes.isNotEmpty) ...[
                _label(context, 'Customer Notes'),
                SizedBox(height: Dimensions.height10 / 2),
                Text(
                  order.customerNotes,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.88,
                    color: context.colors.textPrimary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: Dimensions.height15),
              ],
              if (order.termsAndConditions.isNotEmpty) ...[
                _label(context, 'Terms & Conditions'),
                SizedBox(height: Dimensions.height10 / 2),
                Text(
                  order.termsAndConditions,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.88,
                    color: context.colors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ],

        SizedBox(height: Dimensions.height30),
      ],
    );
  }

  // ── private helpers ────────────────────────────────────────────────────────

  Widget _lineItemRow(BuildContext context, PurchaseOrderLineItem item) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height15,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItemThumbnail(size: Dimensions.height45 * 0.85),
              SizedBox(width: Dimensions.width10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.88,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10 / 3),
                    Text(
                      '${item.quantity.toStringAsFixed(0)} pcs × ₹${item.rate.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.75,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10 / 4),
                    Text(
                      'Warehouse Location: warehouse1',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.72,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${item.net.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.88,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: context.colors.border,
          indent: Dimensions.width20,
          endIndent: Dimensions.width20,
        ),
      ],
    );
  }

  Widget _totalsRow(
    BuildContext context,
    String label,
    double value, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * (bold ? 0.92 : 0.82),
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: context.colors.textPrimary,
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: Dimensions.font16 * (bold ? 0.92 : 0.82),
            fontWeight: FontWeight.w800,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _card(
    BuildContext context, {
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Dimensions.font16 * 0.78,
        fontWeight: FontWeight.w500,
        color: context.colors.textSecondary,
      ),
    );
  }

  Widget _value(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Dimensions.font16 * 0.88,
        fontWeight: FontWeight.w600,
        color: context.colors.textPrimary,
      ),
    );
  }
}
