import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/banking/models/bank_transaction.dart';
import 'package:flutter/material.dart';

/// A single row in the account transaction history list.
///
/// Layout mirrors the banking transaction list screen:
/// ```
/// 19 Jun 2026                        AED315.00
/// Customer Payment                     00001H
/// Customer: Parthiv Ajith         Manually Added
/// ```
class BankTransactionTile extends StatelessWidget {
  final BankTransaction transaction;
  final VoidCallback onTap;

  const BankTransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor = transaction.isCredit
        ? AppColors.success
        : AppColors.warn;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height15,
        ),
        decoration: BoxDecoration(
          color: context.colors.card,
          border: Border(
            bottom: BorderSide(color: context.colors.border),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left column: date, type, party ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatDate(transaction.date),
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.9,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: Dimensions.height10 / 2.5),
                  Text(
                    transaction.type,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.78,
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (transaction.party != null &&
                      transaction.party!.isNotEmpty) ...[
                    SizedBox(height: Dimensions.height10 / 3),
                    Text(
                      transaction.partyLabel != null &&
                              transaction.partyLabel!.isNotEmpty
                          ? '${transaction.partyLabel}: ${transaction.party}'
                          : transaction.party!,
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.72,
                        color: context.colors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: Dimensions.width15),

            // ── Right column: amount, reference, source ────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.currency}${transaction.signedAmount}',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.92,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
                if (transaction.referenceNumber != null &&
                    transaction.referenceNumber!.isNotEmpty) ...[
                  SizedBox(height: Dimensions.height10 / 2.5),
                  Text(
                    transaction.referenceNumber!,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.72,
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                SizedBox(height: Dimensions.height10 / 3),
                Text(
                  transaction.source,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.72,
                    color: context.colors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
