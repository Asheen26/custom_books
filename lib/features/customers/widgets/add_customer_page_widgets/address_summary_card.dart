import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/customers/models/customer_draft.dart';
import 'package:flutter/material.dart';

class AddressSummaryCard extends StatelessWidget {
  final CustomerAddressDraft billing;
  final CustomerAddressDraft shipping;
  final VoidCallback onEdit;

  const AddressSummaryCard({
    super.key,
    required this.billing,
    required this.shipping,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: context.colors.border.withValues(alpha: 0.5),
            blurRadius: Dimensions.radius15 * 0.67,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Address',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.95,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Icon(
                  Icons.edit_outlined,
                  size: Dimensions.iconSize20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (!billing.isEmpty) ...[
            SizedBox(height: Dimensions.height20),
            _addressBlock(context, 'Billing Address', billing),
          ],
          if (!shipping.isEmpty) ...[
            SizedBox(height: Dimensions.height20),
            _addressBlock(context, 'Shipping Address', shipping),
          ],
        ],
      ),
    );
  }

  Widget _addressBlock(
    BuildContext context,
    String title,
    CustomerAddressDraft address,
  ) {
    final lines = <String>[
      address.attention,
      address.street1,
      address.street2,
      address.city,
      _cityStateZip(address),
      address.country,
    ].where((l) => l.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.85,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: Dimensions.height10),
        ...lines.map(
          (line) => Padding(
            padding: EdgeInsets.only(bottom: Dimensions.height10 / 2),
            child: Text(
              line,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.9,
                color: context.colors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
        ),
        if (address.fax.trim().isNotEmpty) ...[
          SizedBox(height: Dimensions.height10 / 2),
          _iconLine(context, Icons.print_outlined, address.fax.trim()),
        ],
        if (address.phone.trim().isNotEmpty) ...[
          SizedBox(height: Dimensions.height10),
          _iconLine(
            context,
            Icons.phone_outlined,
            '${address.phoneCountryCode}-${address.phone.trim()}',
          ),
        ],
      ],
    );
  }

  String _cityStateZip(CustomerAddressDraft a) {
    final state = a.state.trim();
    final zip = a.zipCode.trim();
    if (state.isNotEmpty && zip.isNotEmpty) return '$state - $zip';
    if (state.isNotEmpty) return state;
    return zip;
  }

  Widget _iconLine(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: Dimensions.iconSize16,
          color: context.colors.textSecondary,
        ),
        SizedBox(width: Dimensions.width10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.9,
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
