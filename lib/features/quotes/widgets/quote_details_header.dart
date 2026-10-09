import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/quotes/models/quote_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Summary header card for [QuoteDetailsPage].
class QuoteDetailsHeader extends StatelessWidget {
  final QuoteModel quote;
  const QuoteDetailsHeader({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final statusColor = quote.status.color;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quote Date', style: TextStyle(fontSize: Dimensions.font16 * 0.7, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width10 + 2, vertical: Dimensions.height10 * 0.5),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(Dimensions.radius30)),
                child: Text(quote.status.label, style: TextStyle(fontSize: Dimensions.font16 * 0.62, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: statusColor)),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height10 / 2.5),
          Text(
            quote.quoteDateLabel.isNotEmpty ? quote.quoteDateLabel : DateFormat('dd MMM yyyy').format(quote.quoteDate),
            style: TextStyle(fontSize: Dimensions.font20 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary),
          ),
          SizedBox(height: Dimensions.height20),
          Text(quote.customerName, style: TextStyle(fontSize: Dimensions.font20 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
          SizedBox(height: Dimensions.height10 / 2.5),
          Text(quote.quoteNumber, style: TextStyle(fontSize: Dimensions.font16 * 0.85, fontWeight: FontWeight.w600, color: context.colors.textSecondary)),
          if (quote.subject.isNotEmpty) ...[
            SizedBox(height: Dimensions.height10 / 2.5),
            Text(quote.subject, style: TextStyle(fontSize: Dimensions.font16 * 0.8, color: context.colors.textTertiary)),
          ],
        ],
      ),
    );
  }
}
