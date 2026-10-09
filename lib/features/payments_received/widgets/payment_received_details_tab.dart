import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/features/payments_received/models/payment_received_model.dart';
import 'package:flutter/material.dart';

/// DETAILS tab for [PaymentReceivedDetailsPage].
class PaymentReceivedDetailsTab extends StatelessWidget {
  final PaymentReceivedModel payment;
  const PaymentReceivedDetailsTab({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final summary = payment.amountSummary;
    String fmt(double v) => '${payment.currency.isNotEmpty ? payment.currency : '₹'} ${v.toStringAsFixed(2)}';

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        _card(context, [
          DetailRow(label: 'Payment Mode:', value: payment.mode.label),
          SizedBox(height: Dimensions.height15),
          DetailRow(label: 'Reference#:', value: payment.referenceNumber.isEmpty ? '-' : payment.referenceNumber),
          SizedBox(height: Dimensions.height15),
          DetailRow(label: 'Status:', value: payment.statusLabel.isNotEmpty ? payment.statusLabel : payment.status),
          SizedBox(height: Dimensions.height15),
          DetailRow(label: 'Applied to Invoices:', value: payment.invoiceNumbers.isEmpty ? 'Unapplied' : payment.invoiceNumbers.join(', ')),
          if (payment.notes.isNotEmpty) ...[
            SizedBox(height: Dimensions.height15),
            DetailRow(label: 'Notes:', value: payment.notes),
          ],
        ]),
        SizedBox(height: Dimensions.height15),
        _card(context, [
          _sectionTitle(context, 'Amount Summary'),
          SizedBox(height: Dimensions.height15),
          DetailRow(label: 'Amount Received:', value: fmt(summary.amountReceived)),
          if (summary.bankCharges > 0) ...[
            SizedBox(height: Dimensions.height15),
            DetailRow(label: 'Bank Charges:', value: fmt(summary.bankCharges)),
          ],
          SizedBox(height: Dimensions.height15),
          DetailRow(label: 'Used for Payments:', value: fmt(summary.amountUsedForPayments)),
          SizedBox(height: Dimensions.height15),
          DetailRow(label: 'Amount Refunded:', value: fmt(summary.amountRefunded)),
          SizedBox(height: Dimensions.height15),
          const Divider(height: 1),
          SizedBox(height: Dimensions.height15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amount in Excess:', style: TextStyle(fontSize: Dimensions.font16 * 0.78, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
              Text(fmt(summary.amountInExcess), style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w800, color: AppColors.success)),
            ],
          ),
        ]),
        SizedBox(height: Dimensions.height30),
      ],
    );
  }

  Widget _card(BuildContext context, List<Widget> children) => Container(
    padding: EdgeInsets.all(Dimensions.width20),
    decoration: BoxDecoration(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  Widget _sectionTitle(BuildContext context, String title) => Text(title, style: TextStyle(fontSize: Dimensions.font16 * 0.78, fontWeight: FontWeight.w800, color: context.colors.textSecondary, letterSpacing: 0.4));
}
