import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/banking/models/bank_transaction.dart';
import 'package:flutter/material.dart';

/// Summary header for [BankTransactionDetailsPage].
class BankTxnDetailsHeader extends StatelessWidget {
  final BankTransaction transaction;
  const BankTxnDetailsHeader({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final txn = transaction;
    final amountColor = txn.isCredit ? AppColors.success : AppColors.warn;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  txn.referenceNumber?.isNotEmpty == true ? txn.referenceNumber! : txn.type,
                  style: TextStyle(fontSize: Dimensions.font20 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary),
                ),
              ),
              if (txn.status != null && txn.status!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width10 + 2, vertical: Dimensions.height10 * 0.5),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(Dimensions.radius30)),
                  child: Text(txn.status!.toUpperCase(), style: TextStyle(fontSize: Dimensions.font16 * 0.62, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.success)),
                ),
            ],
          ),
          if (txn.party != null && txn.party!.isNotEmpty) ...[
            SizedBox(height: Dimensions.height10 / 2.5),
            Text(txn.party!, style: TextStyle(fontSize: Dimensions.font16 * 0.85, fontWeight: FontWeight.w600, color: AppColors.primary, decoration: TextDecoration.underline, decorationColor: AppColors.primary)),
          ],
          SizedBox(height: Dimensions.height20),
          Text(txn.isCredit ? 'Amount Received' : 'Amount Paid', style: TextStyle(fontSize: Dimensions.font16 * 0.72, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
          SizedBox(height: Dimensions.height10 / 2.5),
          Text('${txn.currency}${txn.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: Dimensions.font26 * 0.9, fontWeight: FontWeight.w800, color: amountColor)),
          SizedBox(height: Dimensions.height15),
          _metaRow(context, 'Payment Date', formatDate(txn.date)),
          if (txn.referenceNumber != null && txn.referenceNumber!.isNotEmpty) ...[
            SizedBox(height: Dimensions.height10),
            _metaRow(context, 'Reference#', txn.referenceNumber!),
          ],
          if (txn.paymentMode != null && txn.paymentMode!.isNotEmpty) ...[
            SizedBox(height: Dimensions.height10),
            _metaRow(context, 'Payment Mode', txn.paymentMode!),
          ],
        ],
      ),
    );
  }

  Widget _metaRow(BuildContext context, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$label:  ', style: TextStyle(fontSize: Dimensions.font16 * 0.78, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
      Expanded(child: Text(value, style: TextStyle(fontSize: Dimensions.font16 * 0.82, fontWeight: FontWeight.w700, color: context.colors.textPrimary))),
    ],
  );
}
