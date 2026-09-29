import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/customers/models/customer_draft.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:flutter/material.dart';

class MoreInformationSection extends StatefulWidget {
  final CustomerModel customer;

  const MoreInformationSection({super.key, required this.customer});

  @override
  State<MoreInformationSection> createState() => _MoreInformationSectionState();
}

class _MoreInformationSectionState extends State<MoreInformationSection> {
  bool _isMoreInfoExpanded = false;

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
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isMoreInfoExpanded = !_isMoreInfoExpanded;
                });
                appLog(
                  'ℹ️ More Information section tapped: ${_isMoreInfoExpanded ? "expanded" : "collapsed"}',
                  name: 'MoreInformationSection',
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
                      _isMoreInfoExpanded
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
          if (_isMoreInfoExpanded) ...[
            Divider(height: 1, color: context.colors.border),
            Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildInfoRows(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildInfoRows(BuildContext context) {
    final c = widget.customer;

    final paymentTerms =
        CustomerFieldMaps.labelFor(
          CustomerFieldMaps.paymentTerms,
          c.paymentTerms,
        ) ??
        c.paymentTerms;
    final taxTreatment =
        CustomerFieldMaps.labelFor(
          CustomerFieldMaps.taxTreatment,
          c.taxTreatment,
        ) ??
        c.taxTreatment;

    final rows = <Widget?>[
      _infoRow(context, 'Customer Type', _titleCase(c.customerType)),
      _infoRow(context, 'Payment Terms', paymentTerms),
      _infoRow(context, 'Tax Treatment', taxTreatment),
      _infoRow(context, 'GSTIN', c.gstin),
      _infoRow(context, 'Place of Supply', c.placeOfSupply),
      _infoRow(context, 'Currency', c.currency),
      _infoRow(
        context,
        'Portal Access',
        c.allowPortalAccess ? 'Enabled' : 'Disabled',
      ),
    ].whereType<Widget>().toList();

    if (rows.isEmpty) {
      return [
        Text(
          'No additional information available.',
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.85,
            color: context.colors.textTertiary,
          ),
        ),
      ];
    }
    return rows;
  }

  Widget? _infoRow(BuildContext context, String label, String? value) {
    if (value == null || value.trim().isEmpty) return null;
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

  String? _titleCase(String? value) {
    if (value == null || value.isEmpty) return null;
    return value[0].toUpperCase() + value.substring(1);
  }
}
