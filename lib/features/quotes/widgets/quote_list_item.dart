import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/widgets/document_list_tile.dart';
import 'package:custom_books/core/widgets/status_chip.dart';
import 'package:custom_books/features/quotes/models/quote_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuoteListItem extends StatelessWidget {
  final QuoteModel quote;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const QuoteListItem({
    super.key,
    required this.quote,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = quote.quoteDateLabel.isNotEmpty
        ? quote.quoteDateLabel
        : DateFormat('dd MMM yyyy').format(quote.quoteDate);

    final amountLabel = NumberFormat.currency(
      symbol: '${quote.currency} ',
      decimalDigits: 2,
    ).format(quote.totalAmount);

    return DocumentListTile(
      leadingIcon: Icons.request_quote_outlined,
      leadingColor: AppColors.primary,
      primaryText: quote.customerName,
      date: dateLabel,
      documentNumber: quote.quoteNumber,
      statusWidget: StatusChip(
        color: quote.status.color,
        label: quote.status.label,
      ),
      amount: amountLabel,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}