import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/vendors/models/vendor_model.dart';
import 'package:flutter/material.dart';

/// Collapsible Receivables card with currency row, amounts, and
/// "Enter Opening Balance" link — mirrors the reference design.
class VendorReceivablesSection extends StatefulWidget {
  final VendorModel vendor;
  final VoidCallback? onEnterOpeningBalance;

  const VendorReceivablesSection({
    super.key,
    required this.vendor,
    this.onEnterOpeningBalance,
  });

  @override
  State<VendorReceivablesSection> createState() =>
      _VendorReceivablesSectionState();
}

class _VendorReceivablesSectionState extends State<VendorReceivablesSection> {
  bool _expanded = false;

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
          // ── Header row ──────────────────────────────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _expanded = !_expanded);
                appLog(
                  '💰 Receivables section ${_expanded ? "expanded" : "collapsed"}',
                  name: 'VendorReceivablesSection',
                );
              },
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              child: Padding(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Row(
                  children: [
                    // Down-arrow icon (matches reference)
                    Container(
                      width: Dimensions.height45 * 0.85,
                      height: Dimensions.height45 * 0.85,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.colors.textSecondary,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.south_rounded,
                        size: Dimensions.iconSize16,
                        color: context.colors.textSecondary,
                      ),
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
                      _expanded
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

          if (_expanded) ...[
            Divider(height: 1, color: context.colors.border),
            Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Currency row
                  Row(
                    children: [
                      Text(
                        'Indian Rupee',
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
                          'INR',
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

                  // Receivables + Unused Credits
                  Row(
                    children: [
                      Expanded(
                        child: _amountColumn(
                          context,
                          label: 'Receivables',
                          value:
                              '₹${widget.vendor.payables.toStringAsFixed(2)}',
                        ),
                      ),
                      Expanded(
                        child: _amountColumn(
                          context,
                          label: 'Unused Credits',
                          value:
                              '₹${widget.vendor.unusedCredits.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _amountColumn(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.8,
            color: context.colors.textTertiary,
          ),
        ),
        SizedBox(height: Dimensions.height10 / 2),
        Text(
          value,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.9,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Collapsible Payables card with currency row, amounts, and
/// "Enter Opening Balance" link — mirrors the reference design.
class VendorPayablesSection extends StatefulWidget {
  final VendorModel vendor;
  final VoidCallback? onEnterOpeningBalance;

  const VendorPayablesSection({
    super.key,
    required this.vendor,
    this.onEnterOpeningBalance,
  });

  @override
  State<VendorPayablesSection> createState() => _VendorPayablesSectionState();
}

class _VendorPayablesSectionState extends State<VendorPayablesSection> {
  bool _expanded = false;

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
          // ── Header row ──────────────────────────────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _expanded = !_expanded);
                appLog(
                  '📤 Payables section ${_expanded ? "expanded" : "collapsed"}',
                  name: 'VendorPayablesSection',
                );
              },
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              child: Padding(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Row(
                  children: [
                    // Up-arrow icon (matches reference)
                    Container(
                      width: Dimensions.height45 * 0.85,
                      height: Dimensions.height45 * 0.85,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.colors.textSecondary,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.north_rounded,
                        size: Dimensions.iconSize16,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    SizedBox(width: Dimensions.width15),
                    Expanded(
                      child: Text(
                        'Payables',
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded
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

          if (_expanded) ...[
            Divider(height: 1, color: context.colors.border),
            Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Currency row
                  Row(
                    children: [
                      Text(
                        'Indian Rupee',
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
                          'INR',
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

                  // Payables + Unused Credits
                  Row(
                    children: [
                      Expanded(
                        child: _amountColumn(
                          context,
                          label: 'Payables',
                          value:
                              '₹${widget.vendor.payables.toStringAsFixed(2)}',
                        ),
                      ),
                      Expanded(
                        child: _amountColumn(
                          context,
                          label: 'Unused Credits',
                          value:
                              '₹${widget.vendor.unusedCredits.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),

                  // Enter Opening Balance
                  GestureDetector(
                    onTap: () {
                      appLog(
                        '💵 Enter Opening Balance tapped',
                        name: 'VendorPayablesSection',
                      );
                      widget.onEnterOpeningBalance?.call();
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

  Widget _amountColumn(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.8,
            color: context.colors.textTertiary,
          ),
        ),
        SizedBox(height: Dimensions.height10 / 2),
        Text(
          value,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.9,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
