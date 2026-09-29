import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:custom_books/features/invoices/models/invoice_model.dart';
import 'package:custom_books/core/widgets/labeled_text_field.dart';
import 'package:custom_books/features/invoices/widgets/new_invoice_page_widgets/invoice_customer_info_card.dart';
import 'package:custom_books/features/invoices/widgets/new_invoice_page_widgets/email_communications_card.dart';
import 'package:custom_books/features/invoices/widgets/invoice_form_helpers.dart';
import 'package:custom_books/features/invoices/widgets/new_invoice_page_widgets/invoice_tax_and_line_item_section.dart';
import 'package:custom_books/features/invoices/widgets/new_invoice_page_widgets/invoice_more_options_sheet.dart';
import 'package:custom_books/features/invoices/widgets/new_invoice_page_widgets/invoice_attachments_card.dart';
import 'package:flutter/material.dart';

class NewInvoicePage extends StatefulWidget {
  final CustomerModel? customer;
  final InvoiceModel? existingInvoice;

  const NewInvoicePage({super.key, this.customer, this.existingInvoice});

  bool get isEditing => existingInvoice != null;

  @override
  State<NewInvoicePage> createState() => _NewInvoicePageState();
}

class _NewInvoicePageState extends State<NewInvoicePage>
    with UnsavedChangesMixin {
  // Controllers
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _orderNumberController = TextEditingController();
  final TextEditingController _salespersonController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _customerNotesController =
      TextEditingController();
  final TextEditingController _termsController = TextEditingController();

  // Form data
  final String _selectedTaxTreatment = 'VAT Registered';
  String _selectedPlaceOfSupply = 'Dubai';
  late String _invoiceNumber;
  late DateTime _invoiceDate;
  late String _selectedTerms;
  late DateTime _dueDate;
  bool _isTaxInclusive = false;
  final List<InvoiceLineItem> _lineItems = [];
  List<String> _emailCommunications = [];
  bool _paymentReceived = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
    final existing = widget.existingInvoice;

    if (existing != null) {
      // Pre-fill from existing invoice (edit mode)
      _customerNameController.text = existing.customerName;
      _orderNumberController.text = existing.orderNumber ?? '';
      _salespersonController.text = existing.salesperson ?? '';
      _subjectController.text = existing.subject ?? '';
      _customerNotesController.text =
          existing.customerNotes ?? 'Thanks for your business.';
      _termsController.text = existing.termsAndConditions ?? '';
      _selectedPlaceOfSupply = existing.placeOfSupply;
      _invoiceNumber = existing.invoiceNumber;
      _invoiceDate = existing.invoiceDate;
      _selectedTerms = existing.terms;
      _dueDate = existing.dueDate;
      _isTaxInclusive = existing.isTaxInclusive;
      _lineItems.addAll(existing.lineItems);
      _emailCommunications = List<String>.from(existing.emailCommunications);
      _paymentReceived = existing.paymentReceived;
    } else if (widget.customer != null) {
      _customerNameController.text = widget.customer!.name;
      if (widget.customer!.email != null &&
          widget.customer!.email!.isNotEmpty) {
        _emailCommunications.add(widget.customer!.email!);
      }
      _customerNotesController.text = 'Thanks for your business.';
      _invoiceNumber = 'INV-000039';
      _invoiceDate = DateTime.now();
      _selectedTerms = 'Due on Receipt';
      _dueDate = DateTime.now();
    } else {
      _customerNotesController.text = 'Thanks for your business.';
      _invoiceNumber = 'INV-000039';
      _invoiceDate = DateTime.now();
      _selectedTerms = 'Due on Receipt';
      _dueDate = DateTime.now();
    }

    // Track changes for unsaved-changes protection
    _customerNameController.addListener(markDirty);
    _orderNumberController.addListener(markDirty);
    _salespersonController.addListener(markDirty);
    _subjectController.addListener(markDirty);
    _customerNotesController.addListener(markDirty);
    _termsController.addListener(markDirty);

    appLog('📄 NewInvoicePage initialized', name: 'NewInvoicePage');
  }

  @override
  void dispose() {
    _customerNameController.removeListener(markDirty);
    _orderNumberController.removeListener(markDirty);
    _salespersonController.removeListener(markDirty);
    _subjectController.removeListener(markDirty);
    _customerNotesController.removeListener(markDirty);
    _termsController.removeListener(markDirty);
    _customerNameController.dispose();
    _orderNumberController.dispose();
    _salespersonController.dispose();
    _subjectController.dispose();
    _customerNotesController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  /// Simulates preparing the form so the shimmer skeleton is shown briefly.
  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _resetForm() {
    setState(() {
      _customerNameController.clear();
      _orderNumberController.clear();
      _salespersonController.clear();
      _subjectController.clear();
      _customerNotesController.text = 'Thanks for your business.';
      _termsController.clear();
      _selectedPlaceOfSupply = 'Dubai';
      _invoiceDate = DateTime.now();
      _selectedTerms = 'Due on Receipt';
      _dueDate = DateTime.now();
      _isTaxInclusive = false;
      _lineItems.clear();
      _emailCommunications = [];
      _paymentReceived = false;
    });
    markClean();
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
                    // App Bar
                    CustomSliverAppBar(
                      title: widget.isEditing ? 'Edit Invoice' : 'New Invoice',
                      leadingType: AppBarLeadingType.back,
                      onLeadingPressed: () =>
                          onPopInvokedWithResult(false, null),
                      actions: [
                        AppBarElevatedButton(
                          label: widget.isEditing ? 'UPDATE' : 'SAVE AS DRAFT',
                          onPressed: () {
                            appLog(
                              widget.isEditing
                                  ? '💾 Update tapped'
                                  : '💾 Save as Draft tapped',
                              name: 'NewInvoicePage',
                            );
                            if (_customerNameController.text.trim().isEmpty) {
                              ToastificationHelper.showError(
                                context,
                                'Please select a customer before saving.',
                              );
                              return;
                            }
                            ToastificationHelper.showSuccess(
                              context,
                              widget.isEditing
                                  ? 'Invoice updated successfully.'
                                  : 'Invoice saved as draft.',
                            );
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(width: Dimensions.width10),
                        AppBarIconButton(
                          icon: Icons.more_vert_rounded,
                          color: context.colors.textSecondary,
                          onPressed: () {
                            appLog(
                              '⋮ More options pressed',
                              name: 'NewInvoicePage',
                            );
                            showInvoiceMoreOptionsSheet(
                              context,
                              customerNameController: _customerNameController,
                              onResetForm: _resetForm,
                            );
                          },
                        ),
                        SizedBox(width: Dimensions.width20),
                      ],
                    ),

                    // Content
                    SliverPadding(
                      padding: EdgeInsets.all(Dimensions.width20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Customer Information Card
                          InvoiceCustomerInfoCard(
                            customerNameController: _customerNameController,
                            onClearCustomer: () =>
                                setState(() => _customerNameController.clear()),
                            onAddressTap: () => ToastificationHelper.showInfo(
                              context,
                              'Select a customer to manage the address.',
                            ),
                            onCustomerDetailsTap: () =>
                                ToastificationHelper.showInfo(
                                  context,
                                  'Select a customer to view their details.',
                                ),
                            selectedTaxTreatment: _selectedTaxTreatment,
                            onEditTaxTreatmentTap: () =>
                                ToastificationHelper.showInfo(
                                  context,
                                  'Editing tax treatment is coming soon.',
                                ),
                            selectedPlaceOfSupply: _selectedPlaceOfSupply,
                            onPlaceOfSupplyChanged: (value) =>
                                setState(() => _selectedPlaceOfSupply = value!),
                            invoiceNumber: _invoiceNumber,
                            onInvoiceSettingsTap: () =>
                                ToastificationHelper.showInfo(
                                  context,
                                  'Invoice number settings are coming soon.',
                                ),
                            orderNumberController: _orderNumberController,
                            invoiceDate: _invoiceDate,
                            onInvoiceDateSelected: (picked) =>
                                setState(() => _invoiceDate = picked),
                            selectedTerms: _selectedTerms,
                            onTermsChanged: (value) =>
                                setState(() => _selectedTerms = value!),
                            dueDate: _dueDate,
                            onDueDateSelected: (picked) =>
                                setState(() => _dueDate = picked),
                          ),
                          SizedBox(height: Dimensions.height15),

                          // Salesperson & Subject Card
                          FormCard(
                            borderRadius: Dimensions.radius20,
                            showShadow: true,
                            children: [
                              LabeledTextField(
                                label: 'Salesperson',
                                controller: _salespersonController,
                                placeholder: 'Select or Add Salesperson',
                                suffixIcon: Icons.keyboard_arrow_down_rounded,
                              ),
                              SizedBox(height: Dimensions.height20),
                              LabeledTextField(
                                label: 'Subject',
                                controller: _subjectController,
                                placeholder: 'What is this invoice for?',
                                hasInfo: true,
                              ),
                            ],
                          ),

                          SizedBox(height: Dimensions.height15),

                          // Tax & Line Items Section
                          InvoiceTaxAndLineItemSection(
                            isTaxInclusive: _isTaxInclusive,
                            onTaxTypeChanged: (value) {
                              setState(() => _isTaxInclusive = value);
                              markDirty();
                            },
                            onLineItemAdded: (item) {
                              setState(() => _lineItems.add(item));
                              markDirty();
                            },
                          ),

                          SizedBox(height: Dimensions.height15),

                          // Customer Notes Card
                          FormCard(
                            borderRadius: Dimensions.radius20,
                            showShadow: true,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Customer Notes",
                                    style: TextStyle(
                                      fontSize: Dimensions.font16 * 0.85,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: Dimensions.width10 / 2),
                                  Icon(
                                    Icons.info_outline,
                                    size: Dimensions.iconSize16,
                                    color: context.colors.textTertiary,
                                  ),
                                ],
                              ),
                              SizedBox(height: Dimensions.height10),
                              Text(
                                _customerNotesController.text,
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.85,
                                  color: context.colors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: Dimensions.height15),
                              InvoiceFormHelpers.buildSectionHeader(
                                context,
                                'Terms & Conditions',
                              ),
                            ],
                          ),

                          SizedBox(height: Dimensions.height15),

                          // Email Communications Card
                          EmailCommunicationsCard(
                            initialEmails: _emailCommunications,
                            onChanged: (emails) =>
                                _emailCommunications = emails,
                          ),

                          SizedBox(height: Dimensions.height15),

                          // Payment Details Card
                          FormCard(
                            borderRadius: Dimensions.radius20,
                            showShadow: true,
                            children: [
                              InvoiceFormHelpers.buildSectionHeader(
                                context,
                                'Payment Details',
                              ),
                              SizedBox(height: Dimensions.height15),
                              GestureDetector(
                                onTap: () {
                                  setState(
                                    () => _paymentReceived = !_paymentReceived,
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: Dimensions.iconSize24,
                                      height: Dimensions.iconSize24,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radius15 / 3,
                                        ),
                                        border: Border.all(
                                          color: _paymentReceived
                                              ? AppColors.primary
                                              : context.colors.border,
                                          width: 2,
                                        ),
                                        color: _paymentReceived
                                            ? AppColors.primary
                                            : Colors.transparent,
                                      ),
                                      child: _paymentReceived
                                          ? Icon(
                                              Icons.check,
                                              size: Dimensions.iconSize16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: Dimensions.width10),
                                    Expanded(
                                      child: Text(
                                        'I have received the payment',
                                        style: TextStyle(
                                          fontSize: Dimensions.font16 * 0.85,
                                          color: context.colors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: Dimensions.height15),

                          // Attachments Card
                          InvoiceAttachmentsCard(),

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
}
