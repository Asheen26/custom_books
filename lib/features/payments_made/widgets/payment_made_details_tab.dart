import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/features/payments_made/models/payment_made_model.dart';
import 'package:flutter/material.dart';

/// DETAILS tab for [PaymentMadeDetailsPage].
class PaymentMadeDetailsTab extends StatelessWidget {
  final PaymentMadeModel payment;
  const PaymentMadeDetailsTab({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final appliedBills = payment.billNumbers.isEmpty
        ? '—'
        : payment.billNumbers.join(', ');
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: EdgeInsets.all(Dimensions.width20),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailRow(label: 'Payment Mode:', value: payment.mode.label),
              SizedBox(height: Dimensions.height15),
              DetailRow(
                label: 'Reference#:',
                value: payment.referenceNumber.isEmpty
                    ? '—'
                    : payment.referenceNumber,
              ),
              SizedBox(height: Dimensions.height15),
              DetailRow(label: 'Applied to Bills:', value: appliedBills),
              SizedBox(height: Dimensions.height15),
              DetailRow(
                label: 'Amount:',
                value: '₹${payment.amount.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.height30),
      ],
    );
  }
}
