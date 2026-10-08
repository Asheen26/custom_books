import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/customers/models/customer_draft.dart';
import 'package:custom_books/features/customers/views/add_address_page.dart';
import 'package:custom_books/features/customers/views/add_contact_person_page.dart';
import 'package:custom_books/features/customers/widgets/add_customer_page_widgets/address_summary_card.dart';
import 'package:custom_books/features/customers/widgets/add_customer_page_widgets/contact_persons_summary_card.dart';
import 'package:custom_books/features/customers/widgets/add_customer_page_widgets/salutation_selector.dart';
import 'package:custom_books/features/customers/widgets/form_section_card.dart';
import 'package:custom_books/features/vendors/controllers/vendor_form_controller.dart';
import 'package:custom_books/features/vendors/models/vendor_model.dart';
import 'package:flutter/material.dart';

class AddVendorPage extends StatefulWidget {
  final VendorModel? existing;

  const AddVendorPage({super.key, this.existing});

  @override
  State<AddVendorPage> createState() => _AddVendorPageState();
}

class _AddVendorPageState extends State<AddVendorPage>
    with UnsavedChangesMixin {
  final VendorFormController _formController = VendorFormController();

  // ── Text controllers ────────────────────────────────────────────────────────
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mobileController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _websiteController = TextEditingController();
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _remarksController = TextEditingController();

  // ── Dropdown / selection state ──────────────────────────────────────────────
  String _salutation = '';
  String _phoneCountryCode = '+91';
  String _mobileCountryCode = '+91';
  String _selectedCurrency = 'INR- Indian Rupee';
  String _selectedAccountsPayable = 'Select a Accounts Payable';
  String _selectedPaymentTerms = 'Due on Receipt';
  String _selectedDistrict = 'None';

  // ── Checkbox state ──────────────────────────────────────────────────────────
  bool _isMsmeRegistered = false;

  // ── Toggle state ────────────────────────────────────────────────────────────
  bool _showWebsiteSocial = false;

  // ── Address & contact persons ───────────────────────────────────────────────
  CustomerAddressResult? _addressResult;
  final List<CustomerContactPersonDraft> _contactPersons = [];

  // ── Validation ──────────────────────────────────────────────────────────────
  String? _emailError;

  // ── Option lists ────────────────────────────────────────────────────────────
  static const _currencyOptions = [
    'INR- Indian Rupee',
    'USD- United States Dollar',
    'EUR- Euro',
    'GBP- Pound Sterling',
    'AED- UAE Dirham',
    'CAD- Canadian Dollar',
    'AUD- Australian Dollar',
    'SGD- Singapore Dollar',
    'JPY- Japanese Yen',
    'CNY- Yuan Renminbi',
  ];

  static const _accountsPayableOptions = [
    'Select a Accounts Payable',
    'Accounts Payable',
    'Accounts Payable - Domestic',
    'Accounts Payable - Foreign',
  ];

  static const _paymentTermsOptions = [
    'Due on Receipt',
    'Net 15',
    'Net 30',
    'Net 45',
    'Net 60',
    'Due end of the month',
    'Due end of next month',
  ];

  static const _districtOptions = [
    'None',
    'Central',
    'East',
    'North',
    'South',
    'West',
  ];

  static const _currencyCodeMap = {
    'INR- Indian Rupee': 'INR',
    'USD- United States Dollar': 'USD',
    'EUR- Euro': 'EUR',
    'GBP- Pound Sterling': 'GBP',
    'AED- UAE Dirham': 'AED',
    'CAD- Canadian Dollar': 'CAD',
    'AUD- Australian Dollar': 'AUD',
    'SGD- Singapore Dollar': 'SGD',
    'JPY- Japanese Yen': 'JPY',
    'CNY- Yuan Renminbi': 'CNY',
  };

  static const _paymentTermsKeyMap = {
    'Due on Receipt': 'due_on_receipt',
    'Net 15': 'net_15',
    'Net 30': 'net_30',
    'Net 45': 'net_45',
    'Net 60': 'net_60',
    'Due end of the month': 'due_end_of_month',
    'Due end of next month': 'due_end_of_next_month',
  };

  @override
  void initState() {
    super.initState();
    _formController.addListener(_onControllerChanged);

    if (widget.existing != null) {
      final v = widget.existing!;
      _displayNameController.text = v.displayName;
      _companyNameController.text = v.companyName;
      _emailController.text = v.email;
      _phoneController.text = v.phone;
    }

    for (final c in [
      _firstNameController,
      _lastNameController,
      _companyNameController,
      _displayNameController,
      _emailController,
      _phoneController,
      _mobileController,
      _openingBalanceController,
      _websiteController,
      _facebookController,
      _twitterController,
      _remarksController,
    ]) {
      c.addListener(markDirty);
    }
  }

  @override
  void dispose() {
    _formController.removeListener(_onControllerChanged);
    _formController.dispose();
    for (final c in [
      _firstNameController,
      _lastNameController,
      _companyNameController,
      _displayNameController,
      _emailController,
      _phoneController,
      _mobileController,
      _openingBalanceController,
      _websiteController,
      _facebookController,
      _twitterController,
      _remarksController,
    ]) {
      c.removeListener(markDirty);
      c.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _validateEmail(String value) {
    final email = value.trim();
    final valid = email.isEmpty || (email.contains('@') && email.contains('.'));
    setState(() => _emailError = valid ? null : 'Enter a valid email');
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _saveVendor() async {
    final displayName = _displayNameController.text.trim();
    final firstName = _firstNameController.text.trim();
    if (displayName.isEmpty && firstName.isEmpty) {
      ToastificationHelper.showWarning(
        context,
        'Please enter a Display Name before saving.',
      );
      return;
    }
    if (_emailError != null) {
      ToastificationHelper.showWarning(
        context,
        'Please fix the email address.',
      );
      return;
    }

    final resolvedDisplay = displayName.isNotEmpty ? displayName : firstName;

    final body = <String, dynamic>{
      'display_name': resolvedDisplay,
      'first_name': firstName,
      'last_name': _lastNameController.text.trim(),
      'company_name': _companyNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone_country_code': _phoneCountryCode,
      'phone': _phoneController.text.trim(),
      'mobile_country_code': _mobileCountryCode,
      if (_mobileController.text.trim().isNotEmpty)
        'mobile': _mobileController.text.trim(),
      if (_salutation.isNotEmpty) 'salutation': _salutation,
      'is_msme_registered': _isMsmeRegistered,
      if (_currencyCodeMap[_selectedCurrency] != null)
        'currency': _currencyCodeMap[_selectedCurrency],
      if (!_selectedAccountsPayable.startsWith('Select'))
        'accounts_payable': _selectedAccountsPayable,
      if (_openingBalanceController.text.trim().isNotEmpty)
        'opening_balance': _openingBalanceController.text.trim(),
      if (_paymentTermsKeyMap[_selectedPaymentTerms] != null)
        'payment_terms': _paymentTermsKeyMap[_selectedPaymentTerms],
      if (_websiteController.text.trim().isNotEmpty)
        'website': _websiteController.text.trim(),
      if (_facebookController.text.trim().isNotEmpty)
        'facebook': _facebookController.text.trim(),
      if (_twitterController.text.trim().isNotEmpty)
        'twitter': _twitterController.text.trim(),
      if (_remarksController.text.trim().isNotEmpty)
        'remarks': _remarksController.text.trim(),
      if (_selectedDistrict != 'None') 'district': _selectedDistrict,
    };

    if (_addressResult != null) {
      if (!_addressResult!.billing.isEmpty) {
        body['billing_address'] = _addressResult!.billing.toJson();
      }
      if (!_addressResult!.shipping.isEmpty) {
        body['shipping_address'] = _addressResult!.shipping.toJson();
      }
    }

    if (_contactPersons.isNotEmpty) {
      body['contact_persons'] = _contactPersons.map((c) => c.toJson()).toList();
    }

    final isEdit = widget.existing != null;
    final bool success;
    if (isEdit) {
      success = await _formController.update(widget.existing!.id, body);
    } else {
      success = await _formController.create(body);
    }

    if (!mounted) return;

    if (success) {
      markClean();
      final name = _formController.savedVendor?.displayName ?? resolvedDisplay;
      final verb = isEdit ? 'updated' : 'saved';
      ToastificationHelper.showSuccess(context, '$name $verb successfully.');
      Navigator.pop(context, true);
    } else {
      ToastificationHelper.showError(
        context,
        _formController.errorMessage ?? 'Could not save the vendor.',
      );
    }
  }

  // ── Sub-page navigation ─────────────────────────────────────────────────────

  Future<void> _openAddressPage() async {
    appLog('📍 Add Address tapped', name: 'AddVendorPage');
    final result = await Navigator.push<CustomerAddressResult>(
      context,
      MaterialPageRoute(builder: (_) => const AddAddressPage()),
    );
    if (result != null) {
      setState(() => _addressResult = result);
      markDirty();
    }
  }

  Future<void> _openContactPersonPage() async {
    appLog('👤 Add Contact Person tapped', name: 'AddVendorPage');
    final result = await Navigator.push<CustomerContactPersonDraft>(
      context,
      MaterialPageRoute(builder: (_) => const AddContactPersonPage()),
    );
    if (result != null && !result.isEmpty) {
      setState(() => _contactPersons.add(result));
      markDirty();
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              CustomSliverAppBar(
                title: widget.existing == null ? 'New Vendor' : 'Edit Vendor',
                leadingType: AppBarLeadingType.back,
                onLeadingPressed: () => onPopInvokedWithResult(false, null),
                actions: [
                  AppBarIconButton(
                    icon: Icons.contacts_outlined,
                    color: context.colors.textSecondary,
                    onPressed: () => ToastificationHelper.showInfo(
                      context,
                      'Importing from device contacts is coming soon.',
                    ),
                  ),
                  SizedBox(width: Dimensions.width10),
                  AppBarElevatedButton(
                    label: _formController.isSaving ? 'SAVING…' : 'SAVE',
                    onPressed: _formController.isSaving ? null : _saveVendor,
                  ),
                  SizedBox(width: Dimensions.width20),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.all(Dimensions.width20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Vendor Information ─────────────────────────────────
                    FormSectionCard(
                      title: 'Vendor Information',
                      children: [
                        // Salutation + First Name
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _labelRow('Salutation'),
                                  SizedBox(height: Dimensions.height10),
                                  SalutationSelector(
                                    selectedSalutation: _salutation,
                                    onChanged: (v) {
                                      setState(() => _salutation = v);
                                      markDirty();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: Dimensions.width15),
                            Expanded(
                              flex: 2,
                              child: _buildField(
                                label: 'First Name',
                                controller: _firstNameController,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.height20),
                        _buildField(
                          label: 'Last Name',
                          controller: _lastNameController,
                        ),
                        SizedBox(height: Dimensions.height20),
                        _buildField(
                          label: 'Company Name',
                          controller: _companyNameController,
                        ),
                        SizedBox(height: Dimensions.height20),
                        _buildField(
                          label: 'Display Name',
                          controller: _displayNameController,
                          isRequired: true,
                          hasInfo: true,
                        ),
                        SizedBox(height: Dimensions.height20),
                        _buildField(
                          label: 'Email Address',
                          controller: _emailController,
                          hasInfo: true,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailError,
                          onChanged: _validateEmail,
                        ),
                        SizedBox(height: Dimensions.height20),
                        _buildPhoneRow(
                          label: 'Phone',
                          controller: _phoneController,
                          countryCode: _phoneCountryCode,
                          hasInfo: true,
                          onCountryChanged: (v) =>
                              setState(() => _phoneCountryCode = v),
                        ),
                        SizedBox(height: Dimensions.height20),
                        _buildPhoneRow(
                          label: 'Mobile',
                          controller: _mobileController,
                          countryCode: _mobileCountryCode,
                          hasInfo: true,
                          onCountryChanged: (v) =>
                              setState(() => _mobileCountryCode = v),
                        ),
                      ],
                    ),

                    SizedBox(height: Dimensions.height15),

                    // ── Other Details ──────────────────────────────────────
                    FormSectionCard(
                      title: 'Other Details',
                      children: [
                        // MSME Registered
                        _labelRow('MSME Registered?', hasInfo: true),
                        SizedBox(height: Dimensions.height10),
                        Row(
                          children: [
                            SizedBox(
                              width: Dimensions.iconSize24,
                              height: Dimensions.iconSize24,
                              child: Checkbox(
                                value: _isMsmeRegistered,
                                onChanged: (v) {
                                  setState(
                                    () => _isMsmeRegistered = v ?? false,
                                  );
                                  markDirty();
                                },
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radius15 * 0.27,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: Dimensions.width10),
                            Expanded(
                              child: Text(
                                'This vendor is MSME registered',
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.85,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: Dimensions.height20),

                        _buildDropdown(
                          label: 'Default Currency',
                          value: _selectedCurrency,
                          options: _currencyOptions,
                          isRequired: true,
                          onChanged: (v) {
                            setState(() => _selectedCurrency = v);
                            markDirty();
                          },
                        ),

                        SizedBox(height: Dimensions.height20),

                        _buildDropdown(
                          label: 'Accounts Payable',
                          value: _selectedAccountsPayable,
                          options: _accountsPayableOptions,
                          onChanged: (v) {
                            setState(() => _selectedAccountsPayable = v);
                            markDirty();
                          },
                        ),

                        SizedBox(height: Dimensions.height20),

                        // Opening Balance
                        _labelRow('Opening Balance'),
                        SizedBox(height: Dimensions.height10),
                        Row(
                          children: [
                            // Currency label badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.width15,
                                vertical: Dimensions.height15,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.surfaceLight,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radius15,
                                ),
                                border: Border.all(
                                  color: context.colors.border,
                                ),
                              ),
                              child: Text(
                                _currencyCodeMap[_selectedCurrency] ?? 'INR',
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.85,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ),
                            SizedBox(width: Dimensions.width10),
                            Expanded(
                              child: _textInput(
                                controller: _openingBalanceController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: Dimensions.height20),

                        _buildDropdown(
                          label: 'Payment Terms',
                          value: _selectedPaymentTerms,
                          options: _paymentTermsOptions,
                          onChanged: (v) {
                            setState(() => _selectedPaymentTerms = v);
                            markDirty();
                          },
                        ),

                        SizedBox(height: Dimensions.height20),

                        // Website & Social toggle
                        if (_showWebsiteSocial) ...[
                          _buildField(
                            label: 'Website',
                            controller: _websiteController,
                            keyboardType: TextInputType.url,
                          ),
                          SizedBox(height: Dimensions.height20),
                          _buildField(
                            label: 'Facebook',
                            controller: _facebookController,
                            keyboardType: TextInputType.url,
                          ),
                          SizedBox(height: Dimensions.height20),
                          _buildField(
                            label: 'Twitter',
                            controller: _twitterController,
                            keyboardType: TextInputType.url,
                          ),
                          SizedBox(height: Dimensions.height20),
                        ],
                        GestureDetector(
                          onTap: () {
                            setState(
                              () => _showWebsiteSocial = !_showWebsiteSocial,
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _showWebsiteSocial
                                    ? Icons.remove_circle_outline
                                    : Icons.language_outlined,
                                size: Dimensions.iconSize16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: Dimensions.width10),
                              Text(
                                _showWebsiteSocial
                                    ? 'Hide Website & Social'
                                    : 'Add Website & Social',
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.85,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: Dimensions.height15),

                    // ── Add Billing & Shipping address ─────────────────────
                    if (_addressResult == null ||
                        (_addressResult!.billing.isEmpty &&
                            _addressResult!.shipping.isEmpty))
                      _buildExpandableButton(
                        'Add Billing & Shipping address',
                        onTap: _openAddressPage,
                      )
                    else
                      AddressSummaryCard(
                        billing: _addressResult!.billing,
                        shipping: _addressResult!.shipping,
                        onEdit: _openAddressPage,
                      ),

                    SizedBox(height: Dimensions.height15),

                    // ── Add Contact Person ─────────────────────────────────
                    if (_contactPersons.isEmpty)
                      _buildExpandableButton(
                        'Add Contact Person',
                        onTap: _openContactPersonPage,
                      )
                    else
                      ContactPersonsSummaryCard(
                        contactPersons: _contactPersons,
                        onAdd: _openContactPersonPage,
                        onRemove: (index) {
                          setState(() => _contactPersons.removeAt(index));
                          markDirty();
                        },
                      ),

                    SizedBox(height: Dimensions.height15),

                    // ── Custom Fields ──────────────────────────────────────
                    FormSectionCard(
                      title: 'Custom Fields',
                      children: [
                        _buildDropdown(
                          label: 'District',
                          value: _selectedDistrict,
                          options: _districtOptions,
                          onChanged: (v) {
                            setState(() => _selectedDistrict = v);
                            markDirty();
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: Dimensions.height15),

                    // ── Remarks ────────────────────────────────────────────
                    _buildRemarksCard(),

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

  // ── Widget helpers ──────────────────────────────────────────────────────────

  Widget _labelRow(
    String label, {
    bool isRequired = false,
    bool hasInfo = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.85,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        if (isRequired) ...[
          SizedBox(width: Dimensions.width10 / 3),
          Text(
            '*',
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
        if (hasInfo) ...[
          SizedBox(width: Dimensions.width10 / 2),
          Icon(
            Icons.info_outline,
            size: Dimensions.iconSize16,
            color: context.colors.textTertiary,
          ),
        ],
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    bool hasInfo = false,
    String? placeholder,
    TextInputType? keyboardType,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          _labelRow(label, isRequired: isRequired, hasInfo: hasInfo),
          SizedBox(height: Dimensions.height10),
        ],
        _textInput(
          controller: controller,
          keyboardType: keyboardType,
          placeholder: placeholder,
          errorText: errorText,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _textInput({
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? placeholder,
    String? errorText,
    ValueChanged<String>? onChanged,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: Dimensions.font16 * 0.85,
        color: context.colors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(
          color: context.colors.textTertiary,
          fontSize: Dimensions.font16 * 0.85,
        ),
        errorText: errorText,
        errorStyle: TextStyle(
          fontSize: Dimensions.font16 * 0.75,
          color: AppColors.error,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }

  Widget _buildPhoneRow({
    required String label,
    required TextEditingController controller,
    required String countryCode,
    required void Function(String) onCountryChanged,
    bool hasInfo = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelRow(label, hasInfo: hasInfo),
        SizedBox(height: Dimensions.height10),
        Row(
          children: [
            GestureDetector(
              onTap: () => _showCountryCodeSheet(countryCode, onCountryChanged),
              child: Container(
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
            ),
            SizedBox(width: Dimensions.width10),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                onChanged: (_) => markDirty(),
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    bool isRequired = false,
    bool hasInfo = false,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelRow(label, isRequired: isRequired, hasInfo: hasInfo),
        SizedBox(height: Dimensions.height10),
        GestureDetector(
          onTap: () => _showDropdownSheet(label, value, options, onChanged),
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.85,
                      color: value.startsWith('Select')
                          ? context.colors.textTertiary
                          : context.colors.textPrimary,
                      fontWeight: value.startsWith('Select')
                          ? FontWeight.w500
                          : FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: Dimensions.iconSize16 * 1.2,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksCard() {
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
            'Remarks (For Internal Use)',
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.95,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: Dimensions.height20),
          _textInput(
            controller: _remarksController,
            maxLines: 4,
            placeholder: 'Enter internal remarks...',
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableButton(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Dimensions.width10 * 0.7),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                size: Dimensions.iconSize16 * 1.2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: Dimensions.width15),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheets ───────────────────────────────────────────────────────────

  void _showDropdownSheet(
    String label,
    String currentValue,
    List<String> options,
    void Function(String) onChanged,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.card,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height15,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: context.colors.border, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: Dimensions.font20 * 0.85,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close_rounded,
                      size: Dimensions.iconSize24,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.all(Dimensions.width20),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = currentValue == option;
                  if (option.startsWith('Select') && index == 0) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () {
                      onChanged(option);
                      Navigator.pop(context);
                      appLog('✅ Selected: $option', name: 'AddVendorPage');
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: Dimensions.height10),
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width15,
                        vertical: Dimensions.height15,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius15,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : context.colors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: Dimensions.font16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : context.colors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: Dimensions.iconSize24,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryCodeSheet(
    String currentCode,
    void Function(String) onChanged,
  ) {
    const codes = [
      '+91',
      '+971',
      '+1',
      '+44',
      '+61',
      '+65',
      '+81',
      '+86',
      '+49',
      '+33',
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.card,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height15,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: context.colors.border, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Country Code',
                    style: TextStyle(
                      fontSize: Dimensions.font20 * 0.85,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close_rounded,
                      size: Dimensions.iconSize24,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.all(Dimensions.width20),
                itemCount: codes.length,
                itemBuilder: (context, index) {
                  final code = codes[index];
                  final isSelected = currentCode == code;
                  return GestureDetector(
                    onTap: () {
                      onChanged(code);
                      markDirty();
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: Dimensions.height10),
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width15,
                        vertical: Dimensions.height15,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius15,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : context.colors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            code,
                            style: TextStyle(
                              fontSize: Dimensions.font16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : context.colors.textPrimary,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: Dimensions.iconSize24,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
