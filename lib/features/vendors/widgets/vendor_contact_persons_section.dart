import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:flutter/material.dart';

/// Collapsible "Contact Persons" section with an "Add Contact Person" link
/// — mirrors the reference design.
class VendorContactPersonsSection extends StatefulWidget {
  final VoidCallback? onAddContactPerson;

  const VendorContactPersonsSection({super.key, this.onAddContactPerson});

  @override
  State<VendorContactPersonsSection> createState() =>
      _VendorContactPersonsSectionState();
}

class _VendorContactPersonsSectionState
    extends State<VendorContactPersonsSection> {
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
          // ── Header ──────────────────────────────────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _expanded = !_expanded);
                appLog(
                  '👥 Contact Persons ${_expanded ? "expanded" : "collapsed"}',
                  name: 'VendorContactPersonsSection',
                );
              },
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              child: Padding(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: Dimensions.iconSize24,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: Dimensions.width15),
                    Expanded(
                      child: Text(
                        'Contact Persons',
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
                  Text(
                    'You haven\'t added any contact persons for this contact yet.',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.85,
                      color: context.colors.textTertiary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  GestureDetector(
                    onTap: () {
                      appLog(
                        '➕ Add Contact Person tapped',
                        name: 'VendorContactPersonsSection',
                      );
                      widget.onAddContactPerson?.call();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.primary,
                          size: Dimensions.iconSize24,
                        ),
                        SizedBox(width: Dimensions.width10),
                        Text(
                          'Add Contact Person',
                          style: TextStyle(
                            fontSize: Dimensions.font16 * 0.85,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
