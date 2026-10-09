import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/features/sales_orders/models/sales_order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Full scrollable content for [SalesOrderDetailsPage]:
/// info card, line items, totals, notes, terms.
class SoDetailsTab extends StatelessWidget {
  final SalesOrderModel order;
  final String? errorMessage;
  final VoidCallback onRetry;

  const SoDetailsTab({
    super.key,
    required this.order,
    this.errorMessage,
    required this.onRetry,
  });

  NumberFormat get _currency => NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  String _qtyText(double v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        SizedBox(height: Dimensions.height15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
          child: Column(
            children: [
              if (errorMessage != null) ...[
                _errorState(context),
                SizedBox(height: Dimensions.height15),
              ],
              _infoCard(context),
              SizedBox(height: Dimensions.height15),
              _lineItemsCard(context),
              SizedBox(height: Dimensions.height15),
              _totalsCard(context),
              if (order.customerNotes.isNotEmpty) ...[
                SizedBox(height: Dimensions.height15),
                _noteCard(context, 'Customer Notes', order.customerNotes),
              ],
              if (order.termsAndConditions.isNotEmpty) ...[
                SizedBox(height: Dimensions.height15),
                _noteCard(context, 'Terms & Conditions', order.termsAndConditions),
              ],
              SizedBox(height: Dimensions.height30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: Dimensions.iconSize24 * 2, color: context.colors.textTertiary),
          SizedBox(height: Dimensions.height15),
          Text(errorMessage!, textAlign: TextAlign.center, style: TextStyle(fontSize: Dimensions.font16 * 0.9, color: context.colors.textSecondary)),
          SizedBox(height: Dimensions.height20),
          FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context) => _card(context, Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle(context, 'ORDER INFORMATION'),
      SizedBox(height: Dimensions.height15),
      DetailRow(label: 'Reference#:', value: order.referenceNumber.isEmpty ? '—' : order.referenceNumber),
      if (order.expectedShipmentDate != null) ...[
        SizedBox(height: Dimensions.height15),
        DetailRow(label: 'Expected Shipment:', value: formatDate(order.expectedShipmentDate!)),
      ],
      SizedBox(height: Dimensions.height15),
      DetailRow(label: 'Payment Terms:', value: order.paymentTerms),
      if (order.deliveryMethod.isNotEmpty) ...[
        SizedBox(height: Dimensions.height15),
        DetailRow(label: 'Delivery Method:', value: order.deliveryMethod),
      ],
      if (order.salesperson.isNotEmpty) ...[
        SizedBox(height: Dimensions.height15),
        DetailRow(label: 'Salesperson:', value: order.salesperson),
      ],
    ],
  ));

  Widget _lineItemsCard(BuildContext context) => _card(context, Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle(context, 'ITEMS'),
      SizedBox(height: Dimensions.height15),
      if (order.lineItems.isEmpty)
        Text('No items added.', style: TextStyle(fontSize: Dimensions.font16 * 0.85, color: context.colors.textTertiary))
      else
        ...List.generate(order.lineItems.length, (i) {
          final line = order.lineItems[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i == order.lineItems.length - 1 ? 0 : Dimensions.height15),
            child: _lineItemRow(context, line),
          );
        }),
    ],
  ));

  Widget _lineItemRow(BuildContext context, SalesOrderLineItem line) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
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
                  '${_qtyText(line.quantity)} × ${_currency.format(line.rate)}'
                  '${line.discount > 0 ? '  •  -${line.discountIsPercent ? '${_qtyText(line.discount)}%' : _currency.format(line.discount)}' : ''}'
                  '${line.taxRate > 0 ? '  •  ${_qtyText(line.taxRate)}% tax' : ''}',
                  style: TextStyle(fontSize: Dimensions.font16 * 0.75, color: context.colors.textTertiary),
                ),
              ],
            ),
          ),
          SizedBox(width: Dimensions.width10),
          Text(_currency.format(line.total), style: TextStyle(fontSize: Dimensions.font16 * 0.9, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
        ],
      ),
    ],
  );

  Widget _totalsCard(BuildContext context) => _card(context, Column(
    children: [
      _totalRow(context, 'Sub Total', _currency.format(order.subTotal)),
      SizedBox(height: Dimensions.height10),
      _totalRow(context, 'Tax', _currency.format(order.taxAmount)),
      Padding(padding: EdgeInsets.symmetric(vertical: Dimensions.height10), child: Divider(height: 1, color: context.colors.border)),
      _totalRow(context, 'Total', _currency.format(order.total), emphasize: true),
    ],
  ));

  Widget _totalRow(BuildContext context, String label, String value, {bool emphasize = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: emphasize ? Dimensions.font16 : Dimensions.font16 * 0.85, fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500, color: emphasize ? context.colors.textPrimary : context.colors.textSecondary)),
      Text(value, style: TextStyle(fontSize: emphasize ? Dimensions.font20 * 0.95 : Dimensions.font16, fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700, color: emphasize ? AppColors.primary : context.colors.textPrimary)),
    ],
  );

  Widget _noteCard(BuildContext context, String title, String body) => _card(context, Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle(context, title.toUpperCase()),
      SizedBox(height: Dimensions.height10),
      Text(body, style: TextStyle(fontSize: Dimensions.font16 * 0.85, height: 1.5, color: context.colors.textSecondary)),
    ],
  ));

  Widget _card(BuildContext context, Widget child) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(Dimensions.width20),
    decoration: BoxDecoration(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: child,
  );

  Widget _sectionTitle(BuildContext context, String title) => Text(title, style: TextStyle(fontSize: Dimensions.font16 * 0.7, fontWeight: FontWeight.w700, color: context.colors.textTertiary, letterSpacing: 1.2));
}
