import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/banking/models/bank_transaction.dart';
import 'package:flutter/material.dart';

/// PAYMENT HISTORY tab for [BankTransactionDetailsPage].
class BankTxnPaymentHistoryTab extends StatelessWidget {
  final BankTransaction transaction;
  const BankTxnPaymentHistoryTab({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final txn = transaction;
    return ListView(
      padding: EdgeInsets.all(Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: EdgeInsets.all(Dimensions.width20),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Dimensions.height45 * 0.8,
                height: Dimensions.height45 * 0.8,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(Icons.history_rounded, size: Dimensions.iconSize24 - 6, color: AppColors.primary),
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.isCredit
                          ? 'Payment of ${txn.currency}${txn.amount.toStringAsFixed(2)} received'
                          : 'Payment of ${txn.currency}${txn.amount.toStringAsFixed(2)} recorded',
                      style: TextStyle(fontSize: Dimensions.font16 * 0.85, color: context.colors.textPrimary, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                    SizedBox(height: Dimensions.height10 / 2),
                    Text('${txn.source}  •  ${formatDate(txn.date)}', style: TextStyle(fontSize: Dimensions.font16 * 0.7, color: context.colors.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
