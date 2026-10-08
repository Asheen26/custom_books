import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/vendors/models/vendor_model.dart';
import 'package:flutter/material.dart';

/// Displays the vendor name with currency badge, plus tappable
/// Mobile / Work Phone / Email action icons — mirrors the reference design.
class VendorContactInfoSection extends StatelessWidget {
  final VendorModel vendor;
  final VoidCallback? onDial;
  final VoidCallback? onEmail;

  const VendorContactInfoSection({
    super.key,
    required this.vendor,
    this.onDial,
    this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Vendor name + currency badge ────────────────────────────────
          Row(
            children: [
              Container(
                width: Dimensions.height45,
                height: Dimensions.height45,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: Dimensions.iconSize24,
                ),
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Text(
                  vendor.displayName,
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10,
                  vertical: Dimensions.height10 / 3,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(
                    Dimensions.radius15 / 2,
                  ),
                ),
                child: Text(
                  'INR',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.7,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: Dimensions.height20),

          // ── Action icon buttons: Mobile | Work Phone | Email ────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionIconButton(
                icon: Icons.phone_iphone_rounded,
                label: 'Mobile',
                onTap: () {
                  appLog('📱 Mobile tapped', name: 'VendorContactInfoSection');
                  onDial?.call();
                },
              ),
              _ActionIconButton(
                icon: Icons.phone_rounded,
                label: 'Work Phone',
                onTap: () {
                  appLog(
                    '☎️ Work Phone tapped',
                    name: 'VendorContactInfoSection',
                  );
                  onDial?.call();
                },
              ),
              _ActionIconButton(
                icon: Icons.email_outlined,
                label: 'Email',
                onTap: () {
                  appLog('✉️ Email tapped', name: 'VendorContactInfoSection');
                  onEmail?.call();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionIconButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Dimensions.height45 * 1.2,
            height: Dimensions.height45 * 1.2,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: Dimensions.iconSize24,
            ),
          ),
          SizedBox(height: Dimensions.height10 / 2),
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.72,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
