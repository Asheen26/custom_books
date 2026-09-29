import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/customers/widgets/form_section_card.dart';
import 'package:flutter/material.dart';

class OtherDetailsCard extends StatefulWidget {
  final String selectedTaxTreatment;
  final String selectedPlaceOfSupply;
  final String selectedCurrency;
  final String selectedAccountsReceivable;
  final String selectedAccountsPayable;
  final Function(String?) onCurrencyChanged;
  final Function(String?) onAccountsReceivableChanged;
  final Function(String?) onAccountsPayableChanged;

  final Function(String)? onTaxTreatmentChanged;
  final Function(String)? onPlaceOfSupplyChanged;
  final Function(String)? onPaymentTermsChanged;
  final Function(String)? onPortalLanguageChanged;
  final Function(bool)? onAllowPortalChanged;

  final TextEditingController? openingBalanceController;
  final TextEditingController? websiteController;
  final TextEditingController? facebookController;
  final TextEditingController? twitterController;

  const OtherDetailsCard({
    super.key,
    required this.selectedTaxTreatment,
    required this.selectedPlaceOfSupply,
    required this.selectedCurrency,
    required this.selectedAccountsReceivable,
    required this.selectedAccountsPayable,
    required this.onCurrencyChanged,
    required this.onAccountsReceivableChanged,
    required this.onAccountsPayableChanged,
    this.onTaxTreatmentChanged,
    this.onPlaceOfSupplyChanged,
    this.onPaymentTermsChanged,
    this.onPortalLanguageChanged,
    this.onAllowPortalChanged,
    this.openingBalanceController,
    this.websiteController,
    this.facebookController,
    this.twitterController,
  });

  @override
  State<OtherDetailsCard> createState() => _OtherDetailsCardState();
}

class _OtherDetailsCardState extends State<OtherDetailsCard> {
  late String _selectedTaxTreatment;
  late String _selectedPlaceOfSupply;
  late String _selectedCurrency;
  late String _selectedAccountsReceivable;
  String _selectedPaymentTerms = 'Due on Receipt';
  String _selectedPortalLanguage = 'English';
  bool _allowPortalAccess = false;
  bool _showWebsiteSocial = false;

  late final TextEditingController _openingBalanceController =
      widget.openingBalanceController ?? TextEditingController();
  late final TextEditingController _websiteController =
      widget.websiteController ?? TextEditingController();
  late final TextEditingController _facebookController =
      widget.facebookController ?? TextEditingController();
  late final TextEditingController _twitterController =
      widget.twitterController ?? TextEditingController();

  bool get _ownsOpeningBalance => widget.openingBalanceController == null;
  bool get _ownsWebsite => widget.websiteController == null;
  bool get _ownsFacebook => widget.facebookController == null;
  bool get _ownsTwitter => widget.twitterController == null;

  final List<String> _taxTreatmentOptions = [
    'Select a Tax Treatment',
    'GST Registered',
    'Non GST Registered',
    'GST Registered - Composition',
    'Consumer',
    'Overseas',
    'SEZ',
  ];

  final List<String> _placeOfSupplyOptions = [
    'Select a Place Of Supply',
    'Andaman and Nicobar Islands',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chandigarh',
    'Chhattisgarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jammu and Kashmir',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Ladakh',
    'Lakshadweep',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Puducherry',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  final List<String> _currencyOptions = [
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

  final List<String> _accountsReceivableOptions = [
    'Select a Accounts Receivable',
    'Accounts Receivable',
    'Accounts Receivable - Domestic',
    'Accounts Receivable - Foreign',
  ];

  final List<String> _paymentTermsOptions = [
    'Due on Receipt',
    'Net 15',
    'Net 30',
    'Net 45',
    'Net 60',
    'Due end of the month',
    'Due end of next month',
  ];

  final List<String> _portalLanguageOptions = [
    'English',
    'Hindi',
    'Tamil',
    'Telugu',
    'Marathi',
    'Bengali',
    'Gujarati',
    'Kannada',
    'Malayalam',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTaxTreatment = widget.selectedTaxTreatment;
    _selectedPlaceOfSupply = widget.selectedPlaceOfSupply;
    _selectedCurrency = widget.selectedCurrency;
    _selectedAccountsReceivable = widget.selectedAccountsReceivable;
  }

  @override
  void didUpdateWidget(covariant OtherDetailsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTaxTreatment != widget.selectedTaxTreatment) {
      _selectedTaxTreatment = widget.selectedTaxTreatment;
    }
    if (oldWidget.selectedPlaceOfSupply != widget.selectedPlaceOfSupply) {
      _selectedPlaceOfSupply = widget.selectedPlaceOfSupply;
    }
    if (oldWidget.selectedCurrency != widget.selectedCurrency) {
      _selectedCurrency = widget.selectedCurrency;
    }
    if (oldWidget.selectedAccountsReceivable !=
        widget.selectedAccountsReceivable) {
      _selectedAccountsReceivable = widget.selectedAccountsReceivable;
    }
  }

  @override
  void dispose() {
    if (_ownsOpeningBalance) _openingBalanceController.dispose();
    if (_ownsWebsite) _websiteController.dispose();
    if (_ownsFacebook) _facebookController.dispose();
    if (_ownsTwitter) _twitterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      title: 'Other Details',
      children: [
        _buildDropdown(
          'Tax Treatment',
          _selectedTaxTreatment,
          _taxTreatmentOptions,
          isRequired: true,
          onChanged: (value) {
            setState(() => _selectedTaxTreatment = value!);
            widget.onTaxTreatmentChanged?.call(value!);
          },
        ),
        SizedBox(height: Dimensions.height20),
        _buildDropdown(
          'Place Of Supply',
          _selectedPlaceOfSupply,
          _placeOfSupplyOptions,
          isRequired: true,
          onChanged: (value) {
            setState(() => _selectedPlaceOfSupply = value!);
            widget.onPlaceOfSupplyChanged?.call(value!);
          },
        ),
        SizedBox(height: Dimensions.height20),
        _buildDropdown(
          'Currency',
          _selectedCurrency,
          _currencyOptions,
          isRequired: true,
          onChanged: (value) {
            setState(() => _selectedCurrency = value!);
            widget.onCurrencyChanged(value);
          },
        ),
        SizedBox(height: Dimensions.height20),
        _buildDropdown(
          'Accounts Receivable',
          _selectedAccountsReceivable,
          _accountsReceivableOptions,
          onChanged: (value) {
            setState(() => _selectedAccountsReceivable = value!);
            widget.onAccountsReceivableChanged(value);
          },
        ),
        SizedBox(height: Dimensions.height20),
        _buildTextField(
          'Opening Balance',
          _openingBalanceController,
          prefix: '₹',
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: Dimensions.height20),
        _buildDropdown(
          'Payment Terms',
          _selectedPaymentTerms,
          _paymentTermsOptions,
          onChanged: (value) {
            setState(() => _selectedPaymentTerms = value!);
            widget.onPaymentTermsChanged?.call(value!);
          },
        ),
        SizedBox(height: Dimensions.height20),
        Row(
          children: [
            Text(
              "Enable Portal?",
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
            SizedBox(
              width: Dimensions.iconSize24,
              height: Dimensions.iconSize24,
              child: Checkbox(
                value: _allowPortalAccess,
                onChanged: (value) {
                  setState(() => _allowPortalAccess = value ?? false);
                  widget.onAllowPortalChanged?.call(_allowPortalAccess);
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
                "Allow portal access for this customer",
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
          'Portal Language',
          _selectedPortalLanguage,
          _portalLanguageOptions,
          hasInfo: true,
          onChanged: (value) {
            setState(() => _selectedPortalLanguage = value!);
            widget.onPortalLanguageChanged?.call(value!);
          },
        ),
        SizedBox(height: Dimensions.height20),
        if (_showWebsiteSocial) ...[
          _buildTextField(
            'Website',
            _websiteController,
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: Dimensions.height20),
          _buildTextField(
            'Facebook',
            _facebookController,
            hint: 'https://www.facebook.com/',
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: Dimensions.height20),
          _buildTextField(
            'Twitter',
            _twitterController,
            hint: 'https://www.twitter.com/',
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: Dimensions.height20),
        ],
        GestureDetector(
          onTap: () {
            setState(() {
              _showWebsiteSocial = !_showWebsiteSocial;
            });
            appLog(
              _showWebsiteSocial
                  ? '🌐 Website & Social fields shown'
                  : '🌐 Website & Social fields hidden',
              name: 'AddCustomerPage',
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width15,
              vertical: Dimensions.height15,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
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
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController? controller, {
    bool isRequired = false,
    bool hasInfo = false,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
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
          ),
          SizedBox(height: Dimensions.height10),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
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
            prefixText: prefix != null ? '$prefix ' : null,
            prefixStyle: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
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
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options, {
    bool isRequired = false,
    bool hasInfo = false,
    Function(String?)? onChanged,
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
        ),
        SizedBox(height: Dimensions.height10),
        GestureDetector(
          onTap: () =>
              _showDropdownBottomSheet(label, value, options, onChanged),
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

  void _showDropdownBottomSheet(
    String label,
    String currentValue,
    List<String> options,
    Function(String?)? onChanged,
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
                  final isPlaceholder = option.startsWith('Select');

                  if (isPlaceholder && index == 0) {
                    return const SizedBox.shrink();
                  }

                  return GestureDetector(
                    onTap: () {
                      if (onChanged != null) {
                        onChanged(option);
                      }
                      Navigator.pop(context);
                      appLog('✅ Selected: $option', name: 'AddCustomerPage');
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
}
