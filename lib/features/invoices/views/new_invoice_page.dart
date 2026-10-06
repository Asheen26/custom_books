import 'dart:async';
import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/customers/controllers/customers_list_controller.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:custom_books/features/customers/widgets/customer_page_widgets/customer_card_widget.dart';
import 'package:custom_books/features/invoices/controllers/invoice_form_controller.dart';
import 'package:custom_books/features/invoices/models/invoice_model.dart';
import 'package:custom_books/core/widgets/labeled_text_field.dart';
import 'package:custom_books/features/invoices/widgets/new_invoice_page_widgets/invoice_customer_info_card.dart';
import 'package:custom_books/features/invoices/widgets/new_invoice_page_widgets/email_communications_card.dart';
import 'package:custom_books/features/invoices/widgets/invoice_form_helpers.dart';
import 'package:custom_books/features/invoices/widgets/new_invoice_page_widgets/invoice_tax_and_line_item_section.dart';
import 'package:custom_books/features/invoices/widgets/new_invoice_page_widgets/invoice_more_options_sheet.dart';
import 'package:custom_books/features/invoices/widgets/new_invoice_page_widgets/invoice_attachments_card.dart';
import 'package:custom_books/features/invoices/widgets/new_invoice_page_widgets/invoice_number_settings_dialog.dart';
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

  // API controller
  final InvoiceFormController _invoiceController = InvoiceFormController();

  // Form data
  String? _selectedCustomerId; // UUID sent to API
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
    final existing = widget.existingInvoice;

    if (existing != null) {
      // Pre-fill from existing invoice (edit mode)
      _selectedCustomerId = existing.customerId;
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
      _selectedCustomerId = widget.customer!.id;
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
    _invoiceController.dispose();
    super.dispose();
  }

  /// Sets the form as ready. Data is initialised synchronously in initState
  /// so no async work is needed here — the skeleton is skipped entirely.
  Future<void> _load() async {
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
      _selectedCustomerId = null;
      _selectedPlaceOfSupply = 'Dubai';
      // Keep the current invoice number — do not reset to a hardcoded value.
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

  /// Validates form fields and builds the line-items payload.
  /// Returns the payload list, or null if validation failed.
  List<Map<String, dynamic>>? _validateAndBuildPayload(String actionLabel) {
    if (_selectedCustomerId == null || _selectedCustomerId!.isEmpty) {
      ToastificationHelper.showError(
        context,
        'Please select a customer before $actionLabel.',
      );
      return null;
    }
    if (_lineItems.isEmpty) {
      ToastificationHelper.showError(
        context,
        'Please add at least one line item.',
      );
      return null;
    }
    return _lineItems
        .map(
          (item) => {
            'item_id': item.itemId,
            'quantity': item.quantity.toString(),
            'rate': item.rate.toStringAsFixed(2),
          },
        )
        .toList();
  }

  String get _formattedInvoiceDate =>
      '${_invoiceDate.year.toString().padLeft(4, '0')}-'
      '${_invoiceDate.month.toString().padLeft(2, '0')}-'
      '${_invoiceDate.day.toString().padLeft(2, '0')}';

  Future<void> _saveAsDraft() async {
    final lineItemsPayload = _validateAndBuildPayload('saving');
    if (lineItemsPayload == null) return;

    appLog('💾 Save as Draft tapped', name: 'NewInvoicePage');

    final error = await _invoiceController.saveAsDraft(
      customerId: _selectedCustomerId!,
      placeOfSupply: _selectedPlaceOfSupply,
      invoiceDate: _formattedInvoiceDate,
      paymentTerms: InvoiceFormController.termsToApiKey(_selectedTerms),
      subject: _subjectController.text.trim(),
      taxType: _isTaxInclusive ? 'inclusive' : 'exclusive',
      customerNotes: _customerNotesController.text.trim(),
      orderNumber: _orderNumberController.text.trim(),
      lineItems: lineItemsPayload,
    );

    if (!mounted) return;
    if (error == null) {
      markClean();
      ToastificationHelper.showSuccess(context, 'Invoice saved as draft.');
      Navigator.pop(context);
    } else {
      ToastificationHelper.showError(context, error);
    }
  }

  Future<void> _saveAndSend() async {
    final lineItemsPayload = _validateAndBuildPayload('sending');
    if (lineItemsPayload == null) return;

    appLog('📤 Save and Send tapped', name: 'NewInvoicePage');

    final error = await _invoiceController.saveAndSend(
      customerId: _selectedCustomerId!,
      placeOfSupply: _selectedPlaceOfSupply,
      invoiceDate: _formattedInvoiceDate,
      paymentTerms: InvoiceFormController.termsToApiKey(_selectedTerms),
      subject: _subjectController.text.trim(),
      taxType: _isTaxInclusive ? 'inclusive' : 'exclusive',
      customerNotes: _customerNotesController.text.trim(),
      orderNumber: _orderNumberController.text.trim(),
      lineItems: lineItemsPayload,
    );

    if (!mounted) return;
    if (error == null) {
      markClean();
      ToastificationHelper.showSuccess(
        context,
        'Invoice saved and sent successfully.',
      );
      Navigator.pop(context);
    } else {
      ToastificationHelper.showError(context, error);
    }
  }

  Future<void> _updateInvoice() async {
    final invoiceId = widget.existingInvoice?.id;
    if (invoiceId == null || invoiceId.isEmpty) {
      ToastificationHelper.showError(
        context,
        'Cannot update: invoice ID is missing.',
      );
      return;
    }

    final lineItemsPayload = _validateAndBuildPayload('updating');
    if (lineItemsPayload == null) return;

    appLog('\u270f\ufe0f Update Invoice tapped', name: 'NewInvoicePage');

    final error = await _invoiceController.update(
      invoiceId: invoiceId,
      customerId: _selectedCustomerId ?? widget.existingInvoice!.customerId,
      placeOfSupply: _selectedPlaceOfSupply,
      invoiceDate: _formattedInvoiceDate,
      paymentTerms: InvoiceFormController.termsToApiKey(_selectedTerms),
      subject: _subjectController.text.trim(),
      taxType: _isTaxInclusive ? 'inclusive' : 'exclusive',
      customerNotes: _customerNotesController.text.trim(),
      orderNumber: _orderNumberController.text.trim(),
      lineItems: lineItemsPayload,
    );

    if (!mounted) return;
    if (error == null) {
      markClean();
      ToastificationHelper.showSuccess(
        context,
        'Invoice updated successfully.',
      );
      Navigator.pop(context);
    } else {
      ToastificationHelper.showError(context, error);
    }
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
                          onPressed: _invoiceController.isSaving
                              ? null
                              : () {
                                  if (widget.isEditing) {
                                    _updateInvoice();
                                  } else {
                                    _saveAsDraft();
                                  }
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
                              onSaveAndSend: _invoiceController.isSaving
                                  ? null
                                  : _saveAndSend,
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
                            onClearCustomer: () => setState(() {
                              _customerNameController.clear();
                              _selectedCustomerId = null;
                            }),
                            onCustomerNameTap: () async {
                              final picked =
                                  await Navigator.push<CustomerModel>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const _CustomerPickerPage(),
                                    ),
                                  );
                              if (picked != null && mounted) {
                                setState(() {
                                  _selectedCustomerId = picked.id;
                                  _customerNameController.text = picked.name;
                                  if (_emailCommunications.isEmpty &&
                                      picked.email != null &&
                                      picked.email!.isNotEmpty) {
                                    _emailCommunications.add(picked.email!);
                                  }
                                });
                                markDirty();
                              }
                            },
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
                            onInvoiceNumberChanged: (value) =>
                                setState(() => _invoiceNumber = value),
                            onInvoiceSettingsTap: () async {
                              final result =
                                  await InvoiceNumberSettingsDialog.show(
                                    context,
                                    currentInvoiceNumber: _invoiceNumber,
                                  );
                              if (result == null || !mounted) return;
                              setState(() {
                                switch (result.mode) {
                                  case InvoiceNumberMode.autoGenerate:
                                  case InvoiceNumberMode.manualThisInvoice:
                                    if (result.invoiceNumber != null) {
                                      _invoiceNumber = result.invoiceNumber!;
                                    }
                                    break;
                                  case InvoiceNumberMode.manualEachTime:
                                    _invoiceNumber = '';
                                    break;
                                }
                              });
                              markDirty();
                            },
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
                                placeholder: 'Enter salesperson name',
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

// ---------------------------------------------------------------------------
// Lightweight in-page customer picker — shows the existing customers list
// and pops with the selected CustomerModel.
// ---------------------------------------------------------------------------

class _CustomerPickerPage extends StatefulWidget {
  const _CustomerPickerPage();

  @override
  State<_CustomerPickerPage> createState() => _CustomerPickerPageState();
}

class _CustomerPickerPageState extends State<_CustomerPickerPage> {
  final CustomersListController _ctrl = CustomersListController();
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_refresh);
    _scroll.addListener(_onScroll);
    _ctrl.loadFirstPage();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _ctrl.removeListener(_refresh);
    _ctrl.dispose();
    _search.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      _ctrl.loadNextPage();
    }
  }

  void _onSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _ctrl.loadFirstPage(search: _search.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.card,
        title: Text(
          'Select Customer',
          style: TextStyle(
            fontSize: Dimensions.font16,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              0,
              Dimensions.width20,
              Dimensions.height10,
            ),
            child: TextField(
              controller: _search,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search customers…',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: context.colors.surfaceLight,
              ),
            ),
          ),
        ),
      ),
      body: _ctrl.isLoading && _ctrl.customers.isEmpty
          ? const CustomerListSkeleton()
          : _ctrl.customers.isEmpty
          ? const Center(child: Text('No customers found'))
          : ListView.builder(
              controller: _scroll,
              padding: EdgeInsets.all(Dimensions.width20),
              itemCount: _ctrl.customers.length + (_ctrl.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _ctrl.customers.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }
                final customer = _ctrl.customers[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: Dimensions.height10),
                  child: CustomerCardWidget(
                    customer: customer,
                    onTap: () => Navigator.pop(context, customer),
                  ),
                );
              },
            ),
    );
  }
}
