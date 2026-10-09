import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/features/quotes/models/quote_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DETAILS tab for [QuoteDetailsPage].
class QuoteDetailsTab extends StatelessWidget {
  final QuoteModel quote;
  final String? errorMessage;
  final VoidCallback onRetry;

  const QuoteDetailsTab({
    super.key,
    required this.quote,
    this.errorMessage,
    required this.onRetry,
  });

  NumberFormat get _currency => NumberFormat.currency(symbol: '${quote.currency} ', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      children: [
        if (errorMessage != null) ...[
          SizedBox(height: Dimensions.height10),
          _errorBanner(context),
          SizedBox(height: Dimensions.height10),
        ],
        _infoCard(context),
        SizedBox(height: Dimensions.height15),
        _lineItemsCard(context),
        SizedBox(height: Dimensions.height15),
        _totalsCard(context),
        if (quote.customerNotes.isNotEmpty) ...[
          SizedBox(height: Dimensions.height15),
          _noteCard(context, 'Customer Notes', quote.customerNotes),
        ],
        if (quote.termsAndConditions.isNotEmpty) ...[
          SizedBox(height: Dimensions.height15),
          _noteCard(context, 'Terms & Conditions', quote.termsAndConditions),
        ],
        SizedBox(height: Dimensions.height30),
      ],
    );
  }

  Widget _errorBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height10 + 2),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: Dimensions.iconSize16 + 2),
          SizedBox(width: Dimensions.width10),
          Expanded(child: Text(errorMessage!, style: TextStyle(fontSize: Dimensions.font16 * 0.8, color: AppColors.error, fontWeight: FontWeight.w500))),
          GestureDetector(
            onTap: onRetry,
            child: Text('Retry', style: TextStyle(fontSize: Dimensions.font16 * 0.8, color: AppColors.error, fontWeight: FontWeight.w700, decoration: TextDecoration.underline, decorationColor: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return _card(context, Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'QUOTE INFORMATION'),
        SizedBox(height: Dimensions.height15),
        if (quote.referenceNumber.isNotEmpty) ...[
          DetailRow(label: 'Reference#:', value: quote.referenceNumber),
          SizedBox(height: Dimensions.height15),
        ],
        if (quote.expiryDate != null) ...[
          DetailRow(
            label: 'Expiry Date:',
            value: quote.expiryDateLabel.isNotEmpty ? quote.expiryDateLabel : DateFormat('dd MMM yyyy').format(quote.expiryDate!),
          ),
          SizedBox(height: Dimensions.height15),
        ],
        DetailRow(label: 'Tax Type:', value: quote.taxInclusive ? 'Tax Inclusive' : 'Tax Exclusive'),
        if (quote.salesperson.isNotEmpty) ...[
          SizedBox(height: Dimensions.height15),
          DetailRow(label: 'Salesperson:', value: quote.salesperson),
        ],
        if (quote.projectName.isNotEmpty) ...[
          SizedBox(height: Dimensions.height15),
          DetailRow(label: 'Project:', value: quote.projectName),
        ],
      ],
    ));
  }

  Widget _lineItemsCard(BuildContext context) {
    return _card(context, Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'ITEMS'),
        SizedBox(height: Dimensions.height15),
        if (quote.lineItems.isEmpty)
          Text('No items added.', style: TextStyle(fontSize: Dimensions.font16 * 0.85, color: context.colors.textTertiary))
        else
          ...List.generate(quote.lineItems.length, (i) {
            final line = quote.lineItems[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i == quote.lineItems.length - 1 ? 0 : Dimensions.height15),
              child: _lineItemRow(context, line),
            );
          }),
      ],
    ));
  }

  Widget _lineItemRow(BuildContext context, QuoteLineItem line) {
    String qtyText(double v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(line.itemName, style: TextStyle(fontSize: Dimensions.font16 * 0.9, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
              if (line.description.isNotEmpty) ...[
                SizedBox(height: Dimensions.height10 / 3),
                Text(line.description, style: TextStyle(fontSize: Dimensions.font16 * 0.75, color: context.colors.textSecondary)),
              ],
              SizedBox(height: Dimensions.height10 / 2),
              Text(
                '${qtyText(line.quantity)} x ${_currency.format(line.rate)}'
                '${line.discount > 0 ? '  -  ${line.discountIsPercent ? '${qtyText(line.discount)}%' : _currency.format(line.discount)}' : ''}'
                '${line.taxRate > 0 ? '  ${qtyText(line.taxRate)}% tax' : ''}',
                style: TextStyle(fontSize: Dimensions.font16 * 0.75, color: context.colors.textTertiary),
              ),
            ],
          ),
        ),
        SizedBox(width: Dimensions.width10),
        Text(
          line.amount > 0 ? _currency.format(line.amount) : _currency.format(line.quantity * line.rate),
          style: TextStyle(fontSize: Dimensions.font16 * 0.9, fontWeight: FontWeight.w800, color: context.colors.textPrimary),
        ),
      ],
    );
  }

  Widget _totalsCard(BuildContext context) {
    return _card(context, Column(
      children: [
        _totalRow(context, 'Sub Total', _currency.format(quote.subTotal > 0 ? quote.subTotal : quote.totalAmount)),
        SizedBox(height: Dimensions.height10),
        _totalRow(context, 'Tax', _currency.format(quote.taxAmountComputed)),
        Padding(padding: EdgeInsets.symmetric(vertical: Dimensions.height10), child: Divider(height: 1, color: context.colors.border)),
        _totalRow(context, 'Total', _currency.format(quote.totalAmount), emphasize: true),
      ],
    ));
  }

  Widget _totalRow(BuildContext context, String label, String value, {bool emphasize = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: emphasize ? Dimensions.font16 : Dimensions.font16 * 0.85, fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500, color: emphasize ? context.colors.textPrimary : context.colors.textSecondary)),
        Text(value, style: TextStyle(fontSize: emphasize ? Dimensions.font20 * 0.95 : Dimensions.font16, fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700, color: emphasize ? AppColors.primary : context.colors.textPrimary)),
      ],
    );
  }

  Widget _noteCard(BuildContext context, String title, String body) {
    return _card(context, Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, title.toUpperCase()),
        SizedBox(height: Dimensions.height10),
        Text(body, style: TextStyle(fontSize: Dimensions.font16 * 0.85, height: 1.5, color: context.colors.textSecondary)),
      ],
    ));
  }

  Widget _card(BuildContext context, Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title, style: TextStyle(fontSize: Dimensions.font16 * 0.7, fontWeight: FontWeight.w700, color: context.colors.textTertiary, letterSpacing: 1.2));
  }
}
