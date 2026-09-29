import 'package:flutter/material.dart';
import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';

class ReceivablesSectionCard extends StatefulWidget {
  const ReceivablesSectionCard({
    super.key,
    required this.customer,
    required this.onEditCustomer,
  });

  final CustomerModel customer;
  final VoidCallback onEditCustomer;

  @override
  State<ReceivablesSectionCard> createState() => _ReceivablesSectionCardState();
}

class _ReceivablesSectionCardState extends State<ReceivablesSectionCard> {
  bool _isReceivablesExpanded = false;
  void _toggleExpanded() {
    setState(() {
      _isReceivablesExpanded = !_isReceivablesExpanded;
    });
    appLog(
      '💰 Receivables section tapped: ${_isReceivablesExpanded ? "expanded" : "collapsed"}',
      name: 'CustomerDetailsPage',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        Dimensions.width20,
        Dimensions.height15,
        Dimensions.width20,
        0,
      ),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              child: Padding(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: Dimensions.iconSize24,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: Dimensions.width15),
                    Expanded(
                      child: Text(
                        'Receivables',
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _isReceivablesExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: Dimensions.iconSize24,
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isReceivablesExpanded) ...[
            Divider(height: 1, color: context.colors.border),
            Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'UAE Dirham',
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.9,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      SizedBox(width: Dimensions.width10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10,
                          vertical: Dimensions.height10 / 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius15 / 3,
                          ),
                        ),
                        child: Text(
                          '₹',
                          style: TextStyle(
                            fontSize: Dimensions.font16 * 0.7,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height15),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Receivables',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.8,
                                color: context.colors.textTertiary,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10 / 2),
                            Text(
                              '₹${widget.customer.receivables.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.9,
                                fontWeight: FontWeight.w700,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unused Credits',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.8,
                                color: context.colors.textTertiary,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10 / 2),
                            Text(
                              '₹${widget.customer.unusedCredits.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.9,
                                fontWeight: FontWeight.w700,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),

                  GestureDetector(
                    onTap: () {
                      appLog(
                        '💵 Enter Opening Balance tapped',
                        name: 'CustomerDetailsPage',
                      );
                      widget.onEditCustomer();
                    },
                    child: Text(
                      'Enter Opening Balance',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.85,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
