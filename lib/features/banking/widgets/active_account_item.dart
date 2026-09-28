import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/banking/models/bank_account.dart';
import 'package:flutter/material.dart';

class ActiveAccountItem extends StatelessWidget {
  final BankAccount account;
  final VoidCallback? onTap;

  const ActiveAccountItem({super.key, required this.account, this.onTap});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'bank':
      case 'account_balance':
        return Icons.account_balance_rounded;
      case 'cash':
        return Icons.money_rounded;
      case 'undeposited':
      case 'undeposited_funds':
      case 'dollar':
        return Icons.attach_money_rounded;
      case 'credit_card':
        return Icons.credit_card_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      child: Container(
        margin: EdgeInsets.only(bottom: Dimensions.height15),
        padding: EdgeInsets.all(Dimensions.width20),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Dimensions.width10),
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radius15 * 0.7,
                    ),
                  ),
                  child: Icon(
                    _getIconData(account.icon),
                    color: context.colors.textPrimary,
                    size: Dimensions.iconSize24,
                  ),
                ),
                SizedBox(width: Dimensions.width15),
                Text(
                  account.name,
                  style: TextStyle(
                    fontSize: Dimensions.font20 * 0.85,
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount In Zoho Books',
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.7,
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: Dimensions.height10 / 2),
                      Text(
                        '₹${account.amountInZohoBooks.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: Dimensions.font20 * 0.85,
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Dimensions.width10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount In Bank',
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.7,
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: Dimensions.height10 / 2),
                      Text(
                        '₹${account.amountInBank.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: Dimensions.font20 * 0.85,
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
