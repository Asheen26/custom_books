import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/customers/models/customer_draft.dart';
import 'package:flutter/material.dart';

class ContactPersonsSummaryCard extends StatelessWidget {
  final List<CustomerContactPersonDraft> contactPersons;
  final void Function(int index) onRemove;
  final VoidCallback onAdd;

  const ContactPersonsSummaryCard({
    super.key,
    required this.contactPersons,
    required this.onRemove,
    required this.onAdd,
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
          Text(
            'Contact Persons',
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.95,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: Dimensions.height20),
          for (int i = 0; i < contactPersons.length; i++) ...[
            _contactRow(context, contactPersons[i], i),
            SizedBox(height: Dimensions.height15),
            Divider(height: 1, color: context.colors.border),
            SizedBox(height: Dimensions.height15),
          ],
          GestureDetector(
            onTap: onAdd,
            child: Row(
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
                    fontSize: Dimensions.font16 * 0.9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(
    BuildContext context,
    CustomerContactPersonDraft person,
    int index,
  ) {
    final salutationLabel = CustomerFieldMaps.labelFor(
      CustomerFieldMaps.salutation,
      person.salutation,
    );
    final name = [
      ?salutationLabel,
      person.firstName.trim(),
      person.lastName.trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onRemove(index),
          child: Padding(
            padding: EdgeInsets.only(top: Dimensions.height10 / 4),
            child: Icon(
              Icons.cancel_outlined,
              size: Dimensions.iconSize20,
              color: AppColors.error,
            ),
          ),
        ),
        SizedBox(width: Dimensions.width15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (name.isNotEmpty)
                Text(
                  name,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.95,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              if (person.email.trim().isNotEmpty) ...[
                SizedBox(height: Dimensions.height10 / 2),
                Text(
                  person.email.trim(),
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.85,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
              if (person.workPhone.trim().isNotEmpty) ...[
                SizedBox(height: Dimensions.height10),
                _iconLine(
                  context,
                  Icons.phone_outlined,
                  '${person.workPhoneCountryCode}-${person.workPhone.trim()}',
                ),
              ],
              if (person.mobile.trim().isNotEmpty) ...[
                SizedBox(height: Dimensions.height10 / 2),
                _iconLine(
                  context,
                  Icons.smartphone_outlined,
                  '${person.mobileCountryCode}-${person.mobile.trim()}',
                ),
              ],
            ],
          ),
        ),
      ],
    );
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
        Text(
          text,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.9,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
