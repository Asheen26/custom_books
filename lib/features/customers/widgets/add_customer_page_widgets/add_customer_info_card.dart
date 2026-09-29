import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/customers/widgets/add_customer_page_widgets/salutation_selector.dart';
import 'package:custom_books/features/customers/widgets/form_section_card.dart';
import 'package:custom_books/core/widgets/labeled_text_field.dart';
import 'package:flutter/material.dart';

class AddCustomerInfoCard extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController companyNameController;
  final TextEditingController displayNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController mobileController;

  final VoidCallback? onChanged;

  final Function(String)? onCustomerTypeChanged;
  final Function(String)? onSalutationChanged;
  final Function(String?)? onPhoneCountryChanged;
  final Function(String?)? onMobileCountryChanged;

  const AddCustomerInfoCard({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.companyNameController,
    required this.displayNameController,
    required this.emailController,
    required this.phoneController,
    required this.mobileController,
    this.onChanged,
    this.onCustomerTypeChanged,
    this.onSalutationChanged,
    this.onPhoneCountryChanged,
    this.onMobileCountryChanged,
  });

  @override
  State<AddCustomerInfoCard> createState() => _AddCustomerInfoCardState();
}

class _AddCustomerInfoCardState extends State<AddCustomerInfoCard> {
  String _selectedSalutation = '';
  String _phoneCountryCode = '+91';
  String _mobileCountryCode = '+91';
  String _customerType = 'Business';
  String? _emailError;

  void _notifyChanged() => widget.onChanged?.call();

  void _validateEmail(String value) {
    final email = value.trim();
    final bool valid =
        email.isEmpty || (email.contains('@') && email.contains('.com'));
    setState(() => _emailError = valid ? null : 'Enter a valid mail');
  }

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Customer Information',
      children: [
        Row(
          children: [
            Text(
              "Customer Type",
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.85,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            if (true) ...[
              SizedBox(width: Dimensions.width10 / 2),
              Icon(
                Icons.info_outline,
                size: Dimensions.iconSize16,
                color: context.colors.textTertiary,
              ),
            ],
          ],
        ),
        SizedBox(height: Dimensions.height10),
        Row(
          children: [
            Expanded(child: _buildRadioOption('Business')),
            SizedBox(width: Dimensions.width15),
            Expanded(child: _buildRadioOption('Individual')),
          ],
        ),
        SizedBox(height: Dimensions.height20),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salutation',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.85,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: Dimensions.height10),

                  SalutationSelector(
                    selectedSalutation: _selectedSalutation,
                    onChanged: (value) {
                      setState(() {
                        _selectedSalutation = value;
                      });
                      widget.onSalutationChanged?.call(value);
                      _notifyChanged();
                    },
                  ),
                ],
              ),
            ),

            SizedBox(width: Dimensions.width15),

            Expanded(
              flex: 2,
              child: LabeledTextField(
                label: 'First Name',
                controller: widget.firstNameController,
              ),
            ),
          ],
        ),

        SizedBox(height: Dimensions.height20),

        LabeledTextField(
          label: 'Last Name',
          controller: widget.lastNameController,
        ),

        SizedBox(height: Dimensions.height20),

        LabeledTextField(
          label: 'Company Name',
          controller: widget.companyNameController,
        ),

        SizedBox(height: Dimensions.height20),

        LabeledTextField(
          label: 'Display Name',
          controller: widget.displayNameController,
          isRequired: true,
          hasInfo: true,
        ),

        SizedBox(height: Dimensions.height20),

        LabeledTextField(
          label: 'Email Address',
          controller: widget.emailController,
          hasInfo: true,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          onChanged: _validateEmail,
        ),
        SizedBox(height: Dimensions.height20),
        _buildPhoneField('Phone', widget.phoneController, _phoneCountryCode, (
          value,
        ) {
          setState(() => _phoneCountryCode = value!);
          widget.onPhoneCountryChanged?.call(value);
          _notifyChanged();
        }, hasInfo: true),
        SizedBox(height: Dimensions.height20),
        _buildPhoneField(
          'Mobile',
          widget.mobileController,
          _mobileCountryCode,
          (value) {
            setState(() => _mobileCountryCode = value!);
            widget.onMobileCountryChanged?.call(value);
            _notifyChanged();
          },
          hasInfo: true,
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label) {
    final isSelected = _customerType == label;
    return GestureDetector(
      onTap: () {
        setState(() => _customerType = label);
        widget.onCustomerTypeChanged?.call(label);
        _notifyChanged();
        appLog('📝 Customer type changed to: $label', name: 'AddCustomerPage');
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width15,
          vertical: Dimensions.height15,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : context.colors.surfaceLight,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.primary
                  : context.colors.textTertiary,
              size: Dimensions.iconSize16 * 1.2,
            ),
            SizedBox(width: Dimensions.width10),
            Text(
              label,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.85,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField(
    String label,
    TextEditingController controller,
    String countryCode,
    Function(String?) onCountryChanged, {
    bool hasInfo = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.85,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            if (hasInfo) ...[
              SizedBox(width: Dimensions.width10 / 2),
              Icon(
                Icons.info_outline,
                size: Dimensions.iconSize16,
                color: context.colors.textTertiary,
              ),
            ],
          ],
        ),
        SizedBox(height: Dimensions.height10),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width15,
                vertical: Dimensions.height15,
              ),
              decoration: BoxDecoration(
                color: context.colors.surfaceLight,
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    countryCode,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.85,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(width: Dimensions.width10 / 2),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: Dimensions.iconSize16 * 1.2,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
            SizedBox(width: Dimensions.width10),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.85,
                  color: context.colors.textPrimary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.colors.surfaceLight,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width15,
                    vertical: Dimensions.height15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
