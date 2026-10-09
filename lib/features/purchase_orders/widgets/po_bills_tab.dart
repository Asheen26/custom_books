import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:flutter/material.dart';

/// BILLS tab content for [PurchaseOrderDetailsPage].
///
/// Shows an empty-state illustration and a FAB to create the first bill.
class PoBillsTab extends StatelessWidget {
  const PoBillsTab({super.key});

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
                'No bills created so far',
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
            onTap: () => ToastificationHelper.showInfo(
              context,
              'Create Bill coming soon.',
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
        color: AppColors.primary.withValues(alpha: 0.07),
      ),
      child: Icon(
        Icons.receipt_long_rounded,
        size: Dimensions.iconSize24 * 2.2,
        color: AppColors.primaryLight,
      ),
    );
  }
}

// ── shared FAB used by bills and receives tabs ────────────────────────────────

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
