import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/purchase_orders/models/purchase_order_model.dart';
import 'package:custom_books/features/purchase_orders/widgets/po_new_receive_page.dart';
import 'package:flutter/material.dart';

/// RECEIVES tab content for [PurchaseOrderDetailsPage].
///
/// Shows an empty-state illustration and a FAB that opens
/// [PoNewReceivePage].
class PoReceivesTab extends StatelessWidget {
  final PurchaseOrderModel order;

  const PoReceivesTab({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _emptyIllustration(context),
              SizedBox(height: Dimensions.height20),
              Text(
                'No items have been received yet!',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.95,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: Dimensions.width20,
          bottom: Dimensions.height20,
          child: _Fab(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PoNewReceivePage(order: order),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyIllustration(BuildContext context) {
    return Container(
      width: Dimensions.height45 * 3.5,
      height: Dimensions.height45 * 3.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.warning.withValues(alpha: 0.1),
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        size: Dimensions.iconSize24 * 2.2,
        color: AppColors.warning,
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  final VoidCallback onTap;
  const _Fab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Dimensions.height45 * 1.2,
        height: Dimensions.height45 * 1.2,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: Dimensions.radius15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
