import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/items/models/item_model.dart';
import 'package:flutter/material.dart';

/// DETAILS tab for [ItemDetailsPage].
/// Shows stock summary, stock status, sales/purchase grid, and more info.
class ItemDetailsTab extends StatelessWidget {
  final ItemModel item;

  const ItemDetailsTab({super.key, required this.item});

  String _money(double v) => 'AED${v.toStringAsFixed(2)}';
  String get _unitSuffix =>
      (item.unit != null && item.unit!.isNotEmpty) ? ' per ${item.unit}' : '';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        _sectionCard(context,
          icon: Icons.insights_outlined,
          title: 'Stock Summary',
          trailing: Icon(
            Icons.info_outline_rounded,
            size: Dimensions.iconSize16 + 2,
            color: context.colors.textTertiary,
          ),
          child: _buildStockSummary(context),
        ),
        SizedBox(height: Dimensions.height15),
        _sectionCard(context,
          icon: Icons.assessment_outlined,
          title: 'Stock Status',
          child: _buildStockStatus(context),
        ),
        SizedBox(height: Dimensions.height15),
        _sectionCard(context,
          icon: Icons.sell_outlined,
          title: 'Sales & Purchase Information',
          child: _buildSalesPurchaseGrid(context),
        ),
        SizedBox(height: Dimensions.height15),
        _sectionCard(context,
          icon: Icons.grid_view_rounded,
          title: 'More Information',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoField(context, 'Item Type', _itemTypeLabel()),
              _infoField(context, 'SKU', item.sku, placeholder: 'No SKU'),
              _infoField(context, 'Tax', item.tax, placeholder: 'None'),
              _infoField(context, 'Created Source', 'User'),
              _infoField(context, 'Opening Stock', _openingStockLabel(), isLast: true),
            ],
          ),
        ),
        SizedBox(height: Dimensions.height30),
      ],
    );
  }

  Widget _buildStockSummary(BuildContext context) {
    final stockOnHand = item.openingStock ?? 51;
    const committed = 21.0;
    final available = stockOnHand - committed;
    return Column(
      children: [
        _stockRow(context, 'Stock on Hand', stockOnHand),
        SizedBox(height: Dimensions.height15),
        _stockRow(context, 'Committed Stock', committed),
        SizedBox(height: Dimensions.height15),
        _stockRow(context, 'Available for Sale', available),
      ],
    );
  }

  Widget _stockRow(BuildContext context, String label, double value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: Dimensions.font16 * 0.88, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
      Text(value.toStringAsFixed(2), style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
    ],
  );

  Widget _buildStockStatus(BuildContext context) => Row(
    children: [
      Expanded(child: _statusCell(context, '11', 'To be Invoiced')),
      Expanded(child: _statusCell(context, '0', 'To be Billed')),
    ],
  );

  Widget _statusCell(BuildContext context, String qty, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(qty, style: TextStyle(fontSize: Dimensions.font20 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
          SizedBox(width: Dimensions.width10 / 2),
          Text('Qty', style: TextStyle(fontSize: Dimensions.font16 * 0.8, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
      SizedBox(height: Dimensions.height10 / 3),
      Text(label, style: TextStyle(fontSize: Dimensions.font16 * 0.82, color: context.colors.textSecondary)),
    ],
  );

  Widget _buildSalesPurchaseGrid(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _gridCell(context, 'Selling Price', _money(item.salesPrice), subtitle: _unitSuffix.trim().isEmpty ? null : _unitSuffix.trim())),
                VerticalDivider(width: 1, color: context.colors.border),
                Expanded(child: _gridCell(context, 'Purchase Cost', _money(item.purchasePrice), subtitle: _unitSuffix.trim().isEmpty ? null : _unitSuffix.trim())),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.border),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _gridCell(context, 'Sales Account', item.salesAccount ?? 'Sales')),
                VerticalDivider(width: 1, color: context.colors.border),
                Expanded(child: _gridCell(context, 'Purchase Account', item.purchaseAccount ?? 'Cost of Goods Sold')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridCell(BuildContext context, String label, String value, {String? subtitle}) {
    return Padding(
      padding: EdgeInsets.all(Dimensions.width15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: Dimensions.font16 * 0.8, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
          SizedBox(height: Dimensions.height10 / 2),
          Text(value, style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
          if (subtitle != null) ...[
            SizedBox(height: Dimensions.height10 / 4),
            Text(subtitle, style: TextStyle(fontSize: Dimensions.font16 * 0.75, color: context.colors.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _infoField(BuildContext context, String label, String? value, {String placeholder = '—', bool isLast = false}) {
    final hasValue = value != null && value.isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : Dimensions.height20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: Dimensions.font16 * 0.8, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
          SizedBox(height: Dimensions.height10 / 2.5),
          Text(hasValue ? value : placeholder, style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w600, color: hasValue ? context.colors.textPrimary : context.colors.textTertiary)),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context, {required IconData icon, required String title, required Widget child, Widget? trailing}) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: Dimensions.iconSize24 - 4, color: AppColors.primary),
              SizedBox(width: Dimensions.width10),
              Text(title, style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
              if (trailing != null) ...[SizedBox(width: Dimensions.width10 / 2), trailing],
            ],
          ),
          SizedBox(height: Dimensions.height20),
          child,
        ],
      ),
    );
  }

  String _openingStockLabel() {
    final s = item.openingStock ?? 0;
    return s == s.roundToDouble() ? s.toStringAsFixed(0) : s.toStringAsFixed(2);
  }

  String _itemTypeLabel() {
    final sales = item.salesEnabled ?? true;
    final purchase = item.purchaseEnabled ?? true;
    if (sales && purchase) return 'Sales and Purchase Items';
    if (sales) return 'Sales Items';
    if (purchase) return 'Purchase Items';
    return _titleCase(item.itemType) ?? 'Item';
  }

  String? _titleCase(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return v.trim().split(RegExp(r'\s+')).map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}
