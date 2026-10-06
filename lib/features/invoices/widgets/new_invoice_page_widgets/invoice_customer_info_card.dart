import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/features/invoices/widgets/invoice_date_field.dart';
import 'package:custom_books/features/invoices/widgets/invoice_dropdown_field.dart';
import 'package:custom_books/core/widgets/labeled_text_field.dart';
import 'package:custom_books/features/invoices/widgets/invoice_form_helpers.dart';
import 'package:flutter/material.dart';

class InvoiceCustomerInfoCard extends StatelessWidget {
  const InvoiceCustomerInfoCard({
    super.key,
    required this.customerNameController,
    required this.onClearCustomer,
    this.onCustomerNameTap,
    required this.onAddressTap,
    required this.onCustomerDetailsTap,
    required this.selectedTaxTreatment,
    required this.onEditTaxTreatmentTap,
    required this.selectedPlaceOfSupply,
    required this.onPlaceOfSupplyChanged,
    required this.invoiceNumber,
    required this.onInvoiceSettingsTap,
    this.onInvoiceNumberChanged,
    required this.orderNumberController,
    required this.invoiceDate,
    required this.onInvoiceDateSelected,
    required this.selectedTerms,
    required this.onTermsChanged,
    required this.dueDate,
    required this.onDueDateSelected,
  });

  // Customer
  final TextEditingController customerNameController;
  final VoidCallback onClearCustomer;
  final VoidCallback? onCustomerNameTap;
  final VoidCallback onAddressTap;
  final VoidCallback onCustomerDetailsTap;

  // Tax treatment
  final String selectedTaxTreatment;
  final VoidCallback onEditTaxTreatmentTap;

  // Place of supply
  final String selectedPlaceOfSupply;
  final ValueChanged<String?> onPlaceOfSupplyChanged;

  // Invoice number / order number
  final String invoiceNumber;
  final VoidCallback onInvoiceSettingsTap;
  final ValueChanged<String>? onInvoiceNumberChanged;
  final TextEditingController orderNumberController;

  // Dates & terms
  final DateTime invoiceDate;
  final ValueChanged<DateTime> onInvoiceDateSelected;
  final String selectedTerms;
  final ValueChanged<String?> onTermsChanged;
  final DateTime dueDate;
  final ValueChanged<DateTime> onDueDateSelected;

  static const List<String> placeOfSupplyOptions = [
    'Dubai',
    'Abu Dhabi',
    'Sharjah',
    'Ajman',
  ];

  static const List<String> termsOptions = [
    'Due on Receipt',
    'Net 15',
    'Net 30',
    'Net 45',
    'Net 60',
  ];

  @override
  Widget build(BuildContext context) {
    return FormCard(
      borderRadius: Dimensions.radius20,
      showShadow: true,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Customer Name',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.85,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
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
                ),
                SizedBox(height: Dimensions.height10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onCustomerNameTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width15,
                            vertical: Dimensions.height15,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceLight,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius15,
                            ),
                            border: Border.all(color: context.colors.border),
                          ),
                          child: Text(
                            customerNameController.text.isEmpty
                                ? 'Select Customer'
                                : customerNameController.text,
                            style: TextStyle(
                              fontSize: Dimensions.font16 * 0.85,
                              color: customerNameController.text.isEmpty
                                  ? context.colors.textTertiary
                                  : context.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    GestureDetector(
                      onTap: () {
                        onClearCustomer();
                        appLog(
                          '❌ Clear customer tapped',
                          name: 'NewInvoicePage',
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(Dimensions.width10),
                        child: Icon(
                          Icons.close_rounded,
                          size: Dimensions.iconSize24,
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: Dimensions.height15),
            InvoiceFormHelpers.buildLinkRow(context, [
              GestureDetector(
                onTap: () {
                  appLog('📍 Address tapped', name: 'NewInvoicePage');
                  onAddressTap();
                },
                child: Text(
                  'Address',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.85,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  appLog('👤 Customer Details tapped', name: 'NewInvoicePage');
                  onCustomerDetailsTap();
                },
                child: Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.85,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]),
            SizedBox(height: Dimensions.height20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Tax Treatment',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.85,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    GestureDetector(
                      onTap: () {
                        appLog(
                          '✏️ Edit Tax Treatment tapped',
                          name: 'NewInvoicePage',
                        );
                        onEditTaxTreatmentTap();
                      },
                      child: Icon(
                        Icons.edit_outlined,
                        size: Dimensions.iconSize16,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height10),
                Text(
                  selectedTaxTreatment,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.85,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),
            InvoiceDropdownField(
              label: 'Place Of Supply',
              value: selectedPlaceOfSupply,
              options: placeOfSupplyOptions,
              isRequired: true,
              onChanged: onPlaceOfSupplyChanged,
              // onShowSheet: _showDropdownSheet,
            ),
          ],
        ),
        SizedBox(height: Dimensions.height20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Invoice#',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.85,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
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
                ),
                SizedBox(height: Dimensions.height10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width15,
                          vertical: invoiceNumber.isEmpty
                              ? Dimensions.height10 / 2
                              : Dimensions.height15,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceLight,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius15,
                          ),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: invoiceNumber.isEmpty
                            ? TextField(
                                onChanged: onInvoiceNumberChanged,
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.85,
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter invoice number',
                                  hintStyle: TextStyle(
                                    color: context.colors.textTertiary,
                                    fontSize: Dimensions.font16 * 0.85,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              )
                            : Text(
                                invoiceNumber,
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.85,
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    GestureDetector(
                      onTap: () {
                        appLog(
                          '⚙️ Invoice settings tapped',
                          name: 'NewInvoicePage',
                        );
                        onInvoiceSettingsTap();
                      },
                      child: Container(
                        padding: EdgeInsets.all(Dimensions.width10),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceLight,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius15,
                          ),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          size: Dimensions.iconSize24,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),
            LabeledTextField(
              label: 'Order Number',
              controller: orderNumberController,
            ),
            SizedBox(height: Dimensions.height20),
            InvoiceDateField(
              label: 'Invoice Date',
              date: invoiceDate,
              isRequired: true,
              onDateSelected: onInvoiceDateSelected,
            ),
            SizedBox(height: Dimensions.height20),
            InvoiceDropdownField(
              label: 'Terms',
              value: selectedTerms,
              options: termsOptions,
              isRequired: true,
              onChanged: onTermsChanged,
              // onShowSheet: _showDropdownSheet,
            ),
            SizedBox(height: Dimensions.height20),
            InvoiceDateField(
              label: 'Due Date',
              date: dueDate,
              isRequired: true,
              onDateSelected: onDueDateSelected,
            ),
          ],
        ),
      ],
    );
  }
}
