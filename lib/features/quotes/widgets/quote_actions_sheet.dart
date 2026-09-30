import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/quotes/models/quote_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuoteActionsSheet extends StatelessWidget {
  final QuoteModel quote;
  final ValueChanged<QuoteStatus> onStatusChanged;
  final VoidCallback onDelete;

  const QuoteActionsSheet({
    super.key,
    required this.quote,
    required this.onStatusChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      symbol: '${quote.currency} ',
      decimalDigits: 2,
    );
    final statusColor = quote.status.color;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          Dimensions.height10,
          Dimensions.width20,
          Dimensions.height20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quote.quoteNumber,
                    style: TextStyle(
                      fontSize: Dimensions.font20,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10,
                    vertical: Dimensions.height10 / 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                  child: Text(
                    quote.status.label,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.72,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              quote.customerName,
              style: TextStyle(
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: Dimensions.height10 / 2),
            Text(
              'Date: ${quote.quoteDateLabel.isNotEmpty ? quote.quoteDateLabel : quote.quoteDate.toString().substring(0, 10)}'
              '  •  Total: ${currency.format(quote.totalAmount)}',
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.8,
                color: context.colors.textSecondary,
              ),
            ),

            Divider(
              height: Dimensions.height20 * 1.5,
              color: context.colors.border,
            ),

            if (quote.status == QuoteStatus.draft)
              _actionTile(
                context,
                icon: Icons.send_outlined,
                iconColor: AppColors.primaryLight,
                title: 'Mark as Sent',
                onTap: () {
                  Navigator.pop(context);
                  onStatusChanged(QuoteStatus.sent);
                },
              ),

            if (quote.status == QuoteStatus.sent) ...[
              _actionTile(
                context,
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.success,
                title: 'Mark as Accepted',
                onTap: () {
                  Navigator.pop(context);
                  onStatusChanged(QuoteStatus.accepted);
                },
              ),
              _actionTile(
                context,
                icon: Icons.cancel_outlined,
                iconColor: AppColors.error,
                title: 'Mark as Declined',
                onTap: () {
                  Navigator.pop(context);
                  onStatusChanged(QuoteStatus.declined);
                },
              ),
            ],

            if (quote.status == QuoteStatus.accepted)
              _actionTile(
                context,
                icon: Icons.receipt_long_rounded,
                iconColor: AppColors.primary,
                title: 'Convert to Invoice',
                onTap: () {
                  Navigator.pop(context);
                  // Conversion will be handled by the caller.
                  onStatusChanged(QuoteStatus.converted);
                },
              ),

            _actionTile(
              context,
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.error,
              title: 'Delete Quote',
              titleColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? context.colors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}