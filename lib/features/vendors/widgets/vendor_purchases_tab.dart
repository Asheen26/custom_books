import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:flutter/material.dart';

/// The transaction types available under the Purchases tab dropdown.
enum _PurchasesType { bills, billPayment, expenses, purchaseOrder, vendorCredits, journal }

extension _PurchasesTypeLabel on _PurchasesType {
  String get label => switch (this) {
        _PurchasesType.bills => 'Bills',
        _PurchasesType.billPayment => 'Bill Payment',
        _PurchasesType.expenses => 'Expenses',
        _PurchasesType.purchaseOrder => 'Purchase Order',
        _PurchasesType.vendorCredits => 'Vendor Credits',
        _PurchasesType.journal => 'Journal',
      };
}

/// Purchases tab — type selector dropdown (Bills / Bill Payment / Expenses…),
/// filter + sort icons, and an empty-state list body — mirrors the reference.
class VendorPurchasesTab extends StatefulWidget {
  final VoidCallback? onAddTransaction;

  const VendorPurchasesTab({super.key, this.onAddTransaction});

  @override
  State<VendorPurchasesTab> createState() => _VendorPurchasesTabState();
}

class _VendorPurchasesTabState extends State<VendorPurchasesTab> {
  _PurchasesType _selectedType = _PurchasesType.bills;

  void _showTypeMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<_PurchasesType>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      color: context.colors.card,
      items: _PurchasesType.values
          .map(
            (t) => PopupMenuItem<_PurchasesType>(
              value: t,
              child: Text(
                t.label,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.9,
                  color: t == _selectedType
                      ? AppColors.primary
                      : context.colors.textPrimary,
                  fontWeight: t == _selectedType
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    ).then((value) {
      if (value != null && mounted) {
        setState(() => _selectedType = value);
        appLog(
          '📋 Purchases type selected: ${value.label}',
          name: 'VendorPurchasesTab',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Control bar ────────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height10,
          ),
          decoration: BoxDecoration(
            color: context.colors.card,
            border: Border(
              bottom: BorderSide(color: context.colors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Type dropdown button
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => _showTypeMenu(ctx),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedType.label,
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.9,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: Dimensions.iconSize24,
                        color: context.colors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Filter icon
              _ControlIcon(
                icon: Icons.filter_list_rounded,
                onTap: () {
                  appLog('🔍 Filter tapped', name: 'VendorPurchasesTab');
                  ToastificationHelper.showInfo(
                    context,
                    'Filter coming soon.',
                  );
                },
              ),
              SizedBox(width: Dimensions.width10 / 2),
              // Sort icon
              _ControlIcon(
                icon: Icons.swap_vert_rounded,
                onTap: () {
                  appLog('🔀 Sort tapped', name: 'VendorPurchasesTab');
                  ToastificationHelper.showInfo(context, 'Sort coming soon.');
                },
              ),
            ],
          ),
        ),

        // ── Total count label ───────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height10 / 1.5,
          ),
          color: context.colors.surfaceLight,
          child: Text(
            'Total Count',
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.78,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ── List body (empty state) ─────────────────────────────────────────
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: Dimensions.height45 * 3,
                  height: Dimensions.height45 * 3,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceLight,
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.description_outlined,
                      size: Dimensions.height45 * 1.5,
                      color: AppColors.primary.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                Text(
                  'No ${_selectedType.label} created so far.',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.9,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ControlIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ControlIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Dimensions.height45 * 0.95,
        height: Dimensions.height45 * 0.95,
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(Dimensions.radius15 / 1.5),
        ),
        child: Icon(
          icon,
          size: Dimensions.iconSize22,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}
