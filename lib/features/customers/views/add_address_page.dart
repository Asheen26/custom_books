import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/customers/models/customer_draft.dart';
import 'package:flutter/material.dart';

class CustomerAddressResult {
  final CustomerAddressDraft billing;
  final CustomerAddressDraft shipping;

  const CustomerAddressResult({required this.billing, required this.shipping});
}

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage>
    with UnsavedChangesMixin {
  final TextEditingController _billingAttentionController =
      TextEditingController();
  final TextEditingController _billingCountryController =
      TextEditingController();
  final TextEditingController _billingStreet1Controller =
      TextEditingController();
  final TextEditingController _billingStreet2Controller =
      TextEditingController();
  final TextEditingController _billingCityController = TextEditingController();
  final TextEditingController _billingStateController = TextEditingController();
  final TextEditingController _billingZipController = TextEditingController();
  final TextEditingController _billingFaxController = TextEditingController();
  final TextEditingController _billingPhoneController = TextEditingController();

  final TextEditingController _shippingAttentionController =
      TextEditingController();
  final TextEditingController _shippingCountryController =
      TextEditingController();
  final TextEditingController _shippingStreet1Controller =
      TextEditingController();
  final TextEditingController _shippingStreet2Controller =
      TextEditingController();
  final TextEditingController _shippingCityController = TextEditingController();
  final TextEditingController _shippingStateController =
      TextEditingController();
  final TextEditingController _shippingZipController = TextEditingController();
  final TextEditingController _shippingFaxController = TextEditingController();
  final TextEditingController _shippingPhoneController =
      TextEditingController();

  String _billingPhoneCountryCode = '+91';
  String _shippingPhoneCountryCode = '+91';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _billingAttentionController.addListener(markDirty);
    _billingCountryController.addListener(markDirty);
    _billingStreet1Controller.addListener(markDirty);
    _billingStreet2Controller.addListener(markDirty);
    _billingCityController.addListener(markDirty);
    _billingStateController.addListener(markDirty);
    _billingZipController.addListener(markDirty);
    _billingFaxController.addListener(markDirty);
    _billingPhoneController.addListener(markDirty);
    _shippingAttentionController.addListener(markDirty);
    _shippingCountryController.addListener(markDirty);
    _shippingStreet1Controller.addListener(markDirty);
    _shippingStreet2Controller.addListener(markDirty);
    _shippingCityController.addListener(markDirty);
    _shippingStateController.addListener(markDirty);
    _shippingZipController.addListener(markDirty);
    _shippingFaxController.addListener(markDirty);
    _shippingPhoneController.addListener(markDirty);
  }

  @override
  void dispose() {
    _billingAttentionController.removeListener(markDirty);
    _billingCountryController.removeListener(markDirty);
    _billingStreet1Controller.removeListener(markDirty);
    _billingStreet2Controller.removeListener(markDirty);
    _billingCityController.removeListener(markDirty);
    _billingStateController.removeListener(markDirty);
    _billingZipController.removeListener(markDirty);
    _billingFaxController.removeListener(markDirty);
    _billingPhoneController.removeListener(markDirty);
    _shippingAttentionController.removeListener(markDirty);
    _shippingCountryController.removeListener(markDirty);
    _shippingStreet1Controller.removeListener(markDirty);
    _shippingStreet2Controller.removeListener(markDirty);
    _shippingCityController.removeListener(markDirty);
    _shippingStateController.removeListener(markDirty);
    _shippingZipController.removeListener(markDirty);
    _shippingFaxController.removeListener(markDirty);
    _shippingPhoneController.removeListener(markDirty);
    _billingAttentionController.dispose();
    _billingCountryController.dispose();
    _billingStreet1Controller.dispose();
    _billingStreet2Controller.dispose();
    _billingCityController.dispose();
    _billingStateController.dispose();
    _billingZipController.dispose();
    _billingFaxController.dispose();
    _billingPhoneController.dispose();
    _shippingAttentionController.dispose();
    _shippingCountryController.dispose();
    _shippingStreet1Controller.dispose();
    _shippingStreet2Controller.dispose();
    _shippingCityController.dispose();
    _shippingStateController.dispose();
    _shippingZipController.dispose();
    _shippingFaxController.dispose();
    _shippingPhoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _copyBillingToShipping() {
    setState(() {
      _shippingAttentionController.text = _billingAttentionController.text;
      _shippingCountryController.text = _billingCountryController.text;
      _shippingStreet1Controller.text = _billingStreet1Controller.text;
      _shippingStreet2Controller.text = _billingStreet2Controller.text;
      _shippingCityController.text = _billingCityController.text;
      _shippingStateController.text = _billingStateController.text;
      _shippingZipController.text = _billingZipController.text;
      _shippingFaxController.text = _billingFaxController.text;
      _shippingPhoneController.text = _billingPhoneController.text;
      _shippingPhoneCountryCode = _billingPhoneCountryCode;
    });
    appLog('📋 Copied billing address to shipping', name: 'AddAddressPage');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: _isLoading
              ? const FormPageSkeleton(sectionFieldCounts: [3])
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    CustomSliverAppBar(
                      title: 'Address',
                      leadingType: AppBarLeadingType.back,
                      onLeadingPressed: () =>
                          onPopInvokedWithResult(false, null),
                      actions: [
                        AppBarElevatedButton(
                          label: 'SAVE',
                          onPressed: () {
                            appLog(
                              '💾 Save button tapped',
                              name: 'AddAddressPage',
                            );
                            final result = CustomerAddressResult(
                              billing: CustomerAddressDraft(
                                attention: _billingAttentionController.text,
                                country: _billingCountryController.text,
                                street1: _billingStreet1Controller.text,
                                street2: _billingStreet2Controller.text,
                                city: _billingCityController.text,
                                state: _billingStateController.text,
                                zipCode: _billingZipController.text,
                                fax: _billingFaxController.text,
                                phoneCountryCode: _billingPhoneCountryCode,
                                phone: _billingPhoneController.text,
                              ),
                              shipping: CustomerAddressDraft(
                                attention: _shippingAttentionController.text,
                                country: _shippingCountryController.text,
                                street1: _shippingStreet1Controller.text,
                                street2: _shippingStreet2Controller.text,
                                city: _shippingCityController.text,
                                state: _shippingStateController.text,
                                zipCode: _shippingZipController.text,
                                fax: _shippingFaxController.text,
                                phoneCountryCode: _shippingPhoneCountryCode,
                                phone: _shippingPhoneController.text,
                              ),
                            );
                            ToastificationHelper.showSuccess(
                              context,
                              'Address saved.',
                            );
                            markClean();
                            Navigator.pop(context, result);
                          },
                        ),
                        SizedBox(width: Dimensions.width20),
                      ],
                    ),

                    SliverPadding(
                      padding: EdgeInsets.all(Dimensions.width20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildAddressCard(
                            'Billing Address',
                            _billingAttentionController,
                            _billingCountryController,
                            _billingStreet1Controller,
                            _billingStreet2Controller,
                            _billingCityController,
                            _billingStateController,
                            _billingZipController,
                            _billingFaxController,
                            _billingPhoneController,
                            _billingPhoneCountryCode,
                            (value) => setState(
                              () => _billingPhoneCountryCode = value!,
                            ),
                          ),

                          SizedBox(height: Dimensions.height20),

                          Center(
                            child: TextButton(
                              onPressed: _copyBillingToShipping,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.width20,
                                  vertical: Dimensions.height10,
                                ),
                              ),
                              child: Text(
                                'Copy Billing Address',
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: Dimensions.height10),

                          _buildAddressCard(
                            'Shipping Address',
                            _shippingAttentionController,
                            _shippingCountryController,
                            _shippingStreet1Controller,
                            _shippingStreet2Controller,
                            _shippingCityController,
                            _shippingStateController,
                            _shippingZipController,
                            _shippingFaxController,
                            _shippingPhoneController,
                            _shippingPhoneCountryCode,
                            (value) => setState(
                              () => _shippingPhoneCountryCode = value!,
                            ),
                          ),

                          SizedBox(height: Dimensions.height30),
                        ]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(
    String title,
    TextEditingController attentionController,
    TextEditingController countryController,
    TextEditingController street1Controller,
    TextEditingController street2Controller,
    TextEditingController cityController,
    TextEditingController stateController,
    TextEditingController zipController,
    TextEditingController faxController,
    TextEditingController phoneController,
    String phoneCountryCode,
    Function(String?) onCountryChanged,
  ) {
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
            title,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.95,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: Dimensions.height20),
          _buildSimpleTextField('Attention', attentionController),
          SizedBox(height: Dimensions.height15),
          _buildSimpleTextField('Country/Region', countryController),
          SizedBox(height: Dimensions.height15),
          _buildSimpleTextField('Street 1', street1Controller),
          SizedBox(height: Dimensions.height15),
          _buildSimpleTextField('Street 2', street2Controller),
          SizedBox(height: Dimensions.height15),
          _buildSimpleTextField('City', cityController),
          SizedBox(height: Dimensions.height15),
          _buildSimpleTextField('State', stateController),
          SizedBox(height: Dimensions.height15),
          _buildSimpleTextField('Zip Code', zipController),
          SizedBox(height: Dimensions.height15),
          _buildSimpleTextField('Fax', faxController),
          SizedBox(height: Dimensions.height15),
          _buildPhoneField(
            'Phone',
            phoneController,
            phoneCountryCode,
            onCountryChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: Dimensions.font16 * 0.85,
        color: context.colors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: context.colors.textTertiary,
          fontSize: Dimensions.font16 * 0.85,
        ),
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
    );
  }

  Widget _buildPhoneField(
    String label,
    TextEditingController controller,
    String countryCode,
    Function(String?) onCountryChanged,
  ) {
    return Row(
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
              hintText: label,
              hintStyle: TextStyle(
                color: context.colors.textTertiary,
                fontSize: Dimensions.font16 * 0.85,
              ),
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
    );
  }
}
