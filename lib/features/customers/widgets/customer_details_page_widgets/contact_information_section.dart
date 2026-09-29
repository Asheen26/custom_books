import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:flutter/material.dart';

class ContactInformationSection extends StatelessWidget {
  final CustomerModel customer;
  final ValueChanged<String?> onDial;
  final ValueChanged<String?> onSendEmail;

  const ContactInformationSection({
    super.key,
    required this.customer,
    required this.onDial,
    required this.onSendEmail,
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
          Text(
            'CONTACT INFORMATION',
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.7,
              fontWeight: FontWeight.w700,
              color: context.colors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: Dimensions.height20),

          _buildContactInfoRow(
            context: context,
            icon: Icons.phone_iphone_rounded,
            iconColor: const Color(0xFF5C6BC0),
            label: 'Mobile',
            value: customer.mobileNumber,
            placeholder: 'Add mobile number',
            onTap: () {
              appLog('📱 Mobile tapped', name: 'ContactInformationSection');
              onDial(customer.mobileNumber);
            },
          ),

          SizedBox(height: Dimensions.height20),

          _buildContactInfoRow(
            context: context,
            icon: Icons.phone_rounded,
            iconColor: const Color(0xFF5C6BC0),
            label: 'Work Phone',
            value: customer.workPhone,
            placeholder: 'Add work phone',
            onTap: () {
              appLog('☎️ Work Phone tapped', name: 'ContactInformationSection');
              onDial(customer.workPhone);
            },
          ),

          SizedBox(height: Dimensions.height20),

          _buildContactInfoRow(
            context: context,
            icon: Icons.email_rounded,
            iconColor: const Color(0xFF5C6BC0),
            label: 'Email',
            value: customer.email,
            placeholder: 'Add email',
            onTap: () {
              appLog('✉️ Email tapped', name: 'ContactInformationSection');
              onSendEmail(customer.email);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    String? value,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    final hasValue = value != null && value.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: Dimensions.height45,
            height: Dimensions.height45,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radius15 / 1.5),
            ),
            child: Icon(icon, color: iconColor, size: Dimensions.iconSize24),
          ),

          SizedBox(width: Dimensions.width15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.9,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: Dimensions.height10 / 3),
                Text(
                  hasValue ? value : placeholder,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.8,
                    color: hasValue
                        ? context.colors.textSecondary
                        : context.colors.textTertiary,
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
