import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/features/items/models/item_model.dart';
import 'package:flutter/material.dart';

/// Simple transaction row data.
class ItemTxn {
  final String party;
  final String number;
  final DateTime date;
  final double amount;
  final double quantity;
  final double rate;
  final String status;
  const ItemTxn({required this.party, required this.number, required this.date, required this.amount, required this.quantity, required this.rate, required this.status});
}

/// TRANSACTIONS tab for [ItemDetailsPage].
class ItemTransactionsTab extends StatefulWidget {
  final ItemModel item;
  const ItemTransactionsTab({super.key, required this.item});

  @override
  State<ItemTransactionsTab> createState() => _ItemTransactionsTabState();
}

class _ItemTransactionsTabState extends State<ItemTransactionsTab> {
  String _txnType = 'Quotes';

  static const List<String> _txnTypes = [
    'Quotes', 'Invoices', 'Sales Orders', 'Purchase Orders', 'Bills',
  ];

  String _money(double v) => 'AED${v.toStringAsFixed(2)}';

  List<ItemTxn> get _transactions => [
    ItemTxn(party: 'nabeel', number: 'QT-000001', date: DateTime(2026, 7, 2), amount: widget.item.salesPrice, quantity: 1, rate: widget.item.salesPrice, status: 'SENT'),
  ];

  @override
  Widget build(BuildContext context) {
    final txns = _transactions;
    return Column(
      children: [
        Container(
          color: context.colors.surfaceLight,
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _showTypeSheet,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_txnType, style: TextStyle(fontSize: Dimensions.font16 * 1.05, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
                          Icon(Icons.keyboard_arrow_down_rounded, color: context.colors.textPrimary, size: Dimensions.iconSize24 - 2),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.height10 / 3),
                    Text('Total Count', style: TextStyle(fontSize: Dimensions.font16 * 0.78, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ),
              _iconBtn(Icons.filter_alt_outlined, () => ToastificationHelper.showInfo(context, 'Filtering coming soon.')),
              SizedBox(width: Dimensions.width10),
              _iconBtn(Icons.swap_vert_rounded, () => ToastificationHelper.showInfo(context, 'Sorting coming soon.')),
            ],
          ),
        ),
        Expanded(
          child: txns.isEmpty
              ? _emptyState(context)
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: txns.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: context.colors.border),
                  itemBuilder: (_, i) => _txnRow(context, txns[i]),
                ),
        ),
      ],
    );
  }

  Widget _txnRow(BuildContext context, ItemTxn txn) {
    return Container(
      color: context.colors.card,
      padding: EdgeInsets.all(Dimensions.width20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.party, style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
                SizedBox(height: Dimensions.height10 / 3),
                Text(txn.number, style: TextStyle(fontSize: Dimensions.font16 * 0.8, color: context.colors.textSecondary)),
                SizedBox(height: Dimensions.height10 / 4),
                Text(formatDate(txn.date), style: TextStyle(fontSize: Dimensions.font16 * 0.78, color: context.colors.textTertiary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_money(txn.amount), style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
              SizedBox(height: Dimensions.height10 / 3),
              Text('${txn.quantity.toStringAsFixed(2)} * ${_money(txn.rate)}', style: TextStyle(fontSize: Dimensions.font16 * 0.78, color: context.colors.textSecondary)),
              SizedBox(height: Dimensions.height10 / 4),
              Text(txn.status, style: TextStyle(fontSize: Dimensions.font16 * 0.75, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Dimensions.width10),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
          border: Border.all(color: context.colors.border),
        ),
        child: Icon(icon, size: Dimensions.iconSize24 - 4, color: context.colors.textSecondary),
      ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(Dimensions.width20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(Dimensions.width20),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.07), shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_outlined, size: Dimensions.iconSize24 * 2, color: AppColors.primary),
          ),
          SizedBox(height: Dimensions.height20),
          Text('No transactions', style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
          SizedBox(height: Dimensions.height10),
          Text('Transactions for this item will appear here.', textAlign: TextAlign.center, style: TextStyle(fontSize: Dimensions.font16 * 0.8, color: context.colors.textSecondary, height: 1.5)),
        ],
      ),
    ),
  );

  void _showTypeSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radius20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: Dimensions.height15),
            ..._txnTypes.map((t) {
              final sel = t == _txnType;
              return ListTile(
                leading: Icon(sel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: sel ? AppColors.primary : context.colors.textSecondary),
                title: Text(t, style: TextStyle(fontSize: Dimensions.font16 * 0.9, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: context.colors.textPrimary)),
                onTap: () { setState(() => _txnType = t); Navigator.pop(ctx); },
              );
            }),
            SizedBox(height: Dimensions.height20),
          ],
        ),
      ),
    );
  }
}
