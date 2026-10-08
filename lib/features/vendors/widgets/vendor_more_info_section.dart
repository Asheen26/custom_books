import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/vendors/models/vendor_model.dart';
import 'package:flutter/material.dart';

/// Collapsible "More Information" section showing payment terms and other
/// vendor-level fields — mirrors the reference design.
class VendorMoreInfoSection extends StatefulWidget {
  final VendorModel vendor;

  const VendorMoreInfoSection({super.key, required this.vendor});

  @override
  State<VendorMoreInfoSection> createState() => _VendorMoreInfoSectionState();
}

class _VendorMoreInfoSectionState extends State<VendorMoreInfoSection> {
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
                  'ℹ️ More Information ${_expanded ? "expanded" : "collapsed"}',
                  name: 'VendorMoreInfoSection',
                );
              },
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              child: Padding(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Row(
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: Dimensions.iconSize24,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: Dimensions.width15),
                    Expanded(
                      child: Text(
                        'More Information',
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
                  _infoRow(context, 'Payment Terms', 'Due on Receipt'),
                  if (widget.vendor.companyName.isNotEmpty)
                    _infoRow(
                      context,
                      'Company Name',
                      widget.vendor.companyName,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.height15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.8,
              color: context.colors.textTertiary,
            ),
          ),
          SizedBox(height: Dimensions.height10 / 3),
          Text(
            value,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.9,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
