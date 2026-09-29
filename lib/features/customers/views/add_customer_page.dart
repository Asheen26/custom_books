import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/customers/controllers/customer_form_controller.dart';
import 'package:custom_books/features/customers/models/customer_draft.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:custom_books/features/customers/views/add_address_page.dart';
import 'package:custom_books/features/customers/views/add_contact_person_page.dart';
import 'package:custom_books/features/customers/widgets/add_customer_page_widgets/customer_custom_text_field.dart';
import 'package:custom_books/features/customers/widgets/add_customer_page_widgets/add_customer_info_card.dart';
import 'package:custom_books/features/customers/widgets/add_customer_page_widgets/address_summary_card.dart';
import 'package:custom_books/features/customers/widgets/add_customer_page_widgets/contact_persons_summary_card.dart';
import 'package:custom_books/features/customers/widgets/form_section_card.dart';
import 'package:custom_books/features/customers/widgets/add_customer_page_widgets/other_details_card.dart';
import 'package:flutter/material.dart';

class AddCustomerPage extends StatefulWidget {
  final CustomerModel? customer;

  const AddCustomerPage({super.key, this.customer});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage>
    with UnsavedChangesMixin {
  final CustomerFormController _formController = CustomerFormController();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _openingBalanceController =
      TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String _customerType = 'Business';
  String _salutation = '';
  String _phoneCountryCode = '+91';
  String _mobileCountryCode = '+91';

  String _selectedTaxTreatment = 'Select a Tax Treatment';
  String _selectedPlaceOfSupply = 'Select a Place Of Supply';
  String _selectedCurrency = 'INR- Indian Rupee';
  String _selectedAccountsReceivable = 'Select a Accounts Receivable';
  final String _selectedAccountsPayable = 'Select a Accounts Payable';
  String _selectedPaymentTerms = 'Due on Receipt';
  String _selectedPortalLanguage = 'English';
  bool _allowPortalAccess = false;

  CustomerAddressResult? _addressResult;
  final List<CustomerContactPersonDraft> _contactPersons = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _firstNameController.addListener(markDirty);
    _websiteController.addListener(markDirty);
    _facebookController.addListener(markDirty);
    _twitterController.addListener(markDirty);
    _lastNameController.addListener(markDirty);
    _companyNameController.addListener(markDirty);
    _displayNameController.addListener(markDirty);
    _emailController.addListener(markDirty);
    _phoneController.addListener(markDirty);
    _mobileController.addListener(markDirty);
    _openingBalanceController.addListener(markDirty);
    _remarksController.addListener(markDirty);
    if (widget.customer != null) {
      _displayNameController.text = widget.customer!.name;
      _emailController.text = widget.customer!.email ?? '';
      _phoneController.text = widget.customer!.workPhone ?? '';
      _mobileController.text = widget.customer!.mobileNumber ?? '';
      appLog(
        '📝 Editing customer: ${widget.customer!.name}',
        name: 'AddCustomerPage',
      );
    }
  }

  @override
  void dispose() {
    _formController.dispose();
    _firstNameController.removeListener(markDirty);
    _websiteController.removeListener(markDirty);
    _facebookController.removeListener(markDirty);
    _twitterController.removeListener(markDirty);
    _lastNameController.removeListener(markDirty);
    _companyNameController.removeListener(markDirty);
    _displayNameController.removeListener(markDirty);
    _emailController.removeListener(markDirty);
    _phoneController.removeListener(markDirty);
    _mobileController.removeListener(markDirty);
    _openingBalanceController.removeListener(markDirty);
    _remarksController.removeListener(markDirty);
    _firstNameController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _openingBalanceController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
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
              ? const FormPageSkeleton()
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    CustomSliverAppBar(
                      title: widget.customer != null
                          ? 'Edit Customer'
                          : 'New Customer',
                      leadingType: AppBarLeadingType.back,
                      onLeadingPressed: () =>
                          onPopInvokedWithResult(false, null),
                      actions: [
                        AppBarIconButton(
                          icon: Icons.contacts_outlined,
                          color: context.colors.textSecondary,
                          onPressed: () {
                            appLog(
                              '📱 Contacts button tapped',
                              name: 'AddCustomerPage',
                            );
                            ToastificationHelper.showInfo(
                              context,
                              'Importing from device contacts is coming soon.',
                            );
                          },
                        ),
                        SizedBox(width: Dimensions.width10),
                        AppBarElevatedButton(
                          label: _formController.isSaving ? 'SAVING…' : 'SAVE',
                          onPressed: _formController.isSaving
                              ? null
                              : _saveCustomer,
                        ),
                        SizedBox(width: Dimensions.width20),
                      ],
                    ),

                    SliverPadding(
                      padding: EdgeInsets.all(Dimensions.width20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          AddCustomerInfoCard(
                            firstNameController: _firstNameController,
                            lastNameController: _lastNameController,
                            companyNameController: _companyNameController,
                            displayNameController: _displayNameController,
                            emailController: _emailController,
                            phoneController: _phoneController,
                            mobileController: _mobileController,
                            onChanged: markDirty,
                            onCustomerTypeChanged: (v) => _customerType = v,
                            onSalutationChanged: (v) => _salutation = v,
                            onPhoneCountryChanged: (v) =>
                                _phoneCountryCode = v ?? _phoneCountryCode,
                            onMobileCountryChanged: (v) =>
                                _mobileCountryCode = v ?? _mobileCountryCode,
                          ),

                          SizedBox(height: Dimensions.height15),

                          OtherDetailsCard(
                            selectedCurrency: _selectedCurrency,
                            selectedAccountsReceivable:
                                _selectedAccountsReceivable,
                            selectedAccountsPayable: _selectedAccountsPayable,
                            selectedTaxTreatment: _selectedTaxTreatment,
                            selectedPlaceOfSupply: _selectedPlaceOfSupply,
                            openingBalanceController: _openingBalanceController,
                            websiteController: _websiteController,
                            facebookController: _facebookController,
                            twitterController: _twitterController,
                            onTaxTreatmentChanged: (v) =>
                                _selectedTaxTreatment = v,
                            onPlaceOfSupplyChanged: (v) =>
                                _selectedPlaceOfSupply = v,
                            onPaymentTermsChanged: (v) =>
                                _selectedPaymentTerms = v,
                            onPortalLanguageChanged: (v) =>
                                _selectedPortalLanguage = v,
                            onAllowPortalChanged: (v) => _allowPortalAccess = v,
                            onCurrencyChanged: (value) {
                              setState(() => _selectedCurrency = value!);
                              markDirty();
                            },
                            onAccountsReceivableChanged: (value) {
                              setState(
                                () => _selectedAccountsReceivable = value!,
                              );
                              markDirty();
                            },
                            onAccountsPayableChanged: (value) {
                              markDirty();
                            },
                          ),

                          SizedBox(height: Dimensions.height15),

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

                          FormSectionCard(
                            title: 'Remarks (For Internal Use)',
                            children: [
                              CustomerCustomTextField(
                                label: '',
                                controller: _remarksController,
                                maxLines: 4,
                                hint: 'Enter internal remarks...',
                              ),
                            ],
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

  Future<void> _openAddressPage() async {
    appLog('📍 Add Address tapped', name: 'AddCustomerPage');
    final result = await Navigator.push<CustomerAddressResult>(
      context,
      MaterialPageRoute(builder: (context) => const AddAddressPage()),
    );
    if (result != null) {
      setState(() => _addressResult = result);
      markDirty();
    }
  }

  Future<void> _openContactPersonPage() async {
    appLog('👤 Add Contact Person tapped', name: 'AddCustomerPage');
    final result = await Navigator.push<CustomerContactPersonDraft>(
      context,
      MaterialPageRoute(builder: (context) => const AddContactPersonPage()),
    );
    if (result != null && !result.isEmpty) {
      setState(() => _contactPersons.add(result));
      markDirty();
    }
  }

  Map<String, dynamic> _buildRequestBody({
    required String displayName,
    required String firstName,
    required String lastName,
  }) {
    final body = <String, dynamic>{
      'customer_type': _customerType.toLowerCase(),
      if (CustomerFieldMaps.keyFor(CustomerFieldMaps.salutation, _salutation) !=
          null)
        'salutation': CustomerFieldMaps.keyFor(
          CustomerFieldMaps.salutation,
          _salutation,
        ),
      'first_name': firstName,
      'last_name': lastName,
      'company_name': _companyNameController.text.trim(),
      'display_name': displayName,
      'email': _emailController.text.trim(),
      'phone_country_code': _phoneCountryCode,
      'phone': _phoneController.text.trim(),
      'mobile_country_code': _mobileCountryCode,
      'mobile': _mobileController.text.trim(),
      if (CustomerFieldMaps.keyFor(
            CustomerFieldMaps.taxTreatment,
            _selectedTaxTreatment,
          ) !=
          null)
        'tax_treatment': CustomerFieldMaps.keyFor(
          CustomerFieldMaps.taxTreatment,
          _selectedTaxTreatment,
        ),
      if (!_selectedPlaceOfSupply.startsWith('Select'))
        'place_of_supply': _selectedPlaceOfSupply,
      if (CustomerFieldMaps.keyFor(
            CustomerFieldMaps.currency,
            _selectedCurrency,
          ) !=
          null)
        'currency': CustomerFieldMaps.keyFor(
          CustomerFieldMaps.currency,
          _selectedCurrency,
        ),
      if (CustomerFieldMaps.keyFor(
            CustomerFieldMaps.accountsReceivable,
            _selectedAccountsReceivable,
          ) !=
          null)
        'accounts_receivable': CustomerFieldMaps.keyFor(
          CustomerFieldMaps.accountsReceivable,
          _selectedAccountsReceivable,
        ),
      if (CustomerFieldMaps.keyFor(
            CustomerFieldMaps.paymentTerms,
            _selectedPaymentTerms,
          ) !=
          null)
        'payment_terms': CustomerFieldMaps.keyFor(
          CustomerFieldMaps.paymentTerms,
          _selectedPaymentTerms,
        ),
      if (_openingBalanceController.text.trim().isNotEmpty)
        'opening_balance': _openingBalanceController.text.trim(),
      'allow_portal_access': _allowPortalAccess,
      if (CustomerFieldMaps.keyFor(
            CustomerFieldMaps.portalLanguage,
            _selectedPortalLanguage,
          ) !=
          null)
        'portal_language': CustomerFieldMaps.keyFor(
          CustomerFieldMaps.portalLanguage,
          _selectedPortalLanguage,
        ),
      if (_websiteController.text.trim().isNotEmpty)
        'website': _websiteController.text.trim(),
      if (_remarksController.text.trim().isNotEmpty)
        'remarks': _remarksController.text.trim(),
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

    final socialLinks = <Map<String, dynamic>>[];
    if (_websiteController.text.trim().isNotEmpty) {
      socialLinks.add(
        CustomerSocialLinkDraft(
          platform: 'website',
          url: _websiteController.text,
        ).toJson(),
      );
    }
    if (_facebookController.text.trim().isNotEmpty) {
      socialLinks.add(
        CustomerSocialLinkDraft(
          platform: 'facebook',
          url: _facebookController.text,
        ).toJson(),
      );
    }
    if (_twitterController.text.trim().isNotEmpty) {
      socialLinks.add(
        CustomerSocialLinkDraft(
          platform: 'twitter',
          url: _twitterController.text,
        ).toJson(),
      );
    }
    if (socialLinks.isNotEmpty) {
      body['social_links'] = socialLinks;
    }

    return body;
  }

  Future<void> _saveCustomer() async {
    appLog('💾 Save button tapped', name: 'AddCustomerPage');
    final displayName = _displayNameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (displayName.isEmpty && firstName.isEmpty) {
      ToastificationHelper.showError(
        context,
        'Please enter a customer name before saving.',
      );
      return;
    }
    final resolvedDisplayName = displayName.isNotEmpty
        ? displayName
        : firstName;

    final body = _buildRequestBody(
      displayName: resolvedDisplayName,
      firstName: firstName,
      lastName: lastName,
    );

    final isEdit = widget.customer != null;
    final bool success;
    if (isEdit) {
      success = await _formController.update(widget.customer!.id, body);
    } else {
      success = await _formController.create(body);
    }
    if (!mounted) return;

    if (success) {
      markClean();
      final name = _formController.savedCustomer?.name ?? resolvedDisplayName;
      final verb = isEdit ? 'updated' : 'saved';
      ToastificationHelper.showSuccess(context, '$name $verb successfully.');
      Navigator.pop(context, true);
    } else {
      setState(() {});
      ToastificationHelper.showError(
        context,
        _formController.errorMessage ?? 'Could not save the customer.',
      );
    }
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
              decoration: BoxDecoration(
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
}
