import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/widgets/document_list_tile.dart';
import 'package:custom_books/core/widgets/status_chip.dart';
import 'package:custom_books/features/invoices/models/invoice_model.dart';
import 'package:custom_books/features/invoices/views/invoice_details_page.dart';
import 'package:flutter/material.dart';

class InvoiceListItem extends StatelessWidget {
  const InvoiceListItem({super.key, required this.invoice, this.onRefresh});

  final InvoiceModel invoice;

  /// Called when the details page indicates a refresh is needed
  /// (e.g. the invoice was deleted).
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return DocumentListTile(
      leadingIcon: Icons.description_outlined,
      leadingColor: AppColors.primary,
      primaryText: invoice.customerName,
      date: formatDate(invoice.invoiceDate),
      documentNumber: invoice.invoiceNumber,
      subDate: 'Due ${formatDate(invoice.dueDate)}',
      statusWidget: StatusChip(
        color: invoice.status.color,
        label: invoice.status.label,
      ),
      amount: '₹${invoice.total.toStringAsFixed(2)}',
      onTap: () async {
        final needsRefresh = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetailsPage(invoiceId: invoice.id),
          ),
        );
        if (needsRefresh == true) onRefresh?.call();
      },
    );
  }
}
