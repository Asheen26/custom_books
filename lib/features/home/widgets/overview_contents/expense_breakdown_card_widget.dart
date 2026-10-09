import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/widgets/bottom_sheet_header.dart';
import 'package:custom_books/features/home/models/expense_item_model.dart';
import 'package:custom_books/features/home/widgets/card_tile_widget.dart';
import 'package:flutter/material.dart';

String _periodLabel(String value) {
  switch (value) {
    case 'this_fiscal_year':
      return 'This Fiscal Year';
    case 'last_fiscal_year':
      return 'Last Fiscal Year';
    case 'this_year':
      return 'This Year';
    case 'this_month':
      return 'This Month';
    case 'last_month':
      return 'Last Month';
    default:
      return value;
  }
}

class ExpenseBreakdownCardWidget extends StatefulWidget {
  final List<ExpenseItem> apiData;
  final List<String> availablePeriods;
  final String currency;

  final void Function(String period)? onPeriodChanged;

  const ExpenseBreakdownCardWidget({
    super.key,
    this.apiData = const [],
    this.availablePeriods = const ['This Fiscal Year'],
    this.currency = 'INR',
    this.onPeriodChanged,
  });

  @override
  State<ExpenseBreakdownCardWidget> createState() =>
      _ExpenseBreakdownCardWidgetState();
}

class _ExpenseBreakdownCardWidgetState
    extends State<ExpenseBreakdownCardWidget> {
  String _selectedPeriod = 'this_fiscal_year';

  String get _sym {
    switch (widget.currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '${widget.currency} ';
    }
  }

  List<ExpenseItem> get _topExpenses => widget.apiData;

  void _showPeriodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _PeriodPickerSheet(
        title: 'Select Period',
        sectionLabel: 'EXPENSE BREAKDOWN PERIOD',
        selectedPeriod: _selectedPeriod,
        periods: widget.availablePeriods,
        onSelected: (period) {
          Navigator.pop(sheetCtx);
          setState(() => _selectedPeriod = period);
          widget.onPeriodChanged?.call(period);
        },
        onClose: () => Navigator.pop(sheetCtx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sym = _sym;
    final total = _topExpenses.fold<double>(0, (p, e) => p + e.amount);
    return Container(
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardTitle(
                title: 'Expense Breakdown',
                icon: Icons.donut_small_rounded,
              ),
              GestureDetector(
                onTap: _showPeriodSheet,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10,
                    vertical: Dimensions.height10 * 0.4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radius30),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _periodLabel(_selectedPeriod),
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.72,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      SizedBox(width: Dimensions.width10 * 0.4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: Dimensions.iconSize16,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height10 * 0.8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Expenses',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.82,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textSecondary,
                ),
              ),
              Text(
                '$sym${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 1.05,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height10),
          Divider(height: 1, color: context.colors.border),
          SizedBox(height: Dimensions.height10),
          ..._topExpenses.map((e) {
            final ratio = total == 0 ? 0.0 : (e.amount / total).clamp(0.0, 1.0);
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: Dimensions.height10 / 1.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.label,
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.85,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$sym${e.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.85,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10 / 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radius15 * 0.67,
                    ),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: Dimensions.height10 * 0.6,
                      backgroundColor: context.colors.border,
                      valueColor: AlwaysStoppedAnimation(e.color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PeriodPickerSheet extends StatelessWidget {
  final String title;
  final String sectionLabel;
  final String selectedPeriod;
  final List<String> periods;
  final ValueChanged<String> onSelected;
  final VoidCallback onClose;

  const _PeriodPickerSheet({
    required this.title,
    required this.sectionLabel,
    required this.selectedPeriod,
    required this.periods,
    required this.onSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimensions.radius20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: Dimensions.height15),
            BottomSheetHeader(title: title, onClose: onClose, showBorder: true),
            Padding(
              padding: EdgeInsets.fromLTRB(
                Dimensions.width20,
                Dimensions.height20,
                Dimensions.width20,
                Dimensions.height10,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  sectionLabel,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.7,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
              child: Column(
                children: [
                  for (int i = 0; i < periods.length; i++) ...[
                    _PeriodTile(
                      period: periods[i],
                      isSelected: periods[i] == selectedPeriod,
                      onTap: () => onSelected(periods[i]),
                    ),
                    if (i < periods.length - 1)
                      SizedBox(height: Dimensions.height10),
                  ],
                ],
              ),
            ),
            SizedBox(height: Dimensions.height20),
          ],
        ),
      ),
    );
  }
}

class _PeriodTile extends StatelessWidget {
  final String period;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTile({
    required this.period,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : context.colors.card,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : context.colors.border,
          ),
        ),
        child: Row(
          children: [
            RadioGroup<bool>(
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              child: Radio<bool>(
                value: true,
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            SizedBox(width: Dimensions.width10 * 0.5),
            Expanded(
              child: Text(
                _periodLabel(period),
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : context.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
