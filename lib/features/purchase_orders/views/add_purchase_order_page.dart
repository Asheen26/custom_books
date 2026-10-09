import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/line_item/add_line_item_page.dart';
import 'package:custom_books/core/line_item/item_lookup_model.dart';
import 'package:custom_books/core/models/attachment_file.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/attachment_picker.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/line_item_form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/purchase_orders/models/purchase_order_model.dart';
import 'package:flutter/material.dart';

// ── Deliver-to destination ─────────────────────────────────────────────────────
enum _DeliverTo { warehouse, customer }

class AddPurchaseOrderPage extends StatefulWidget {
  final PurchaseOrderModel? existing;

  const AddPurchaseOrderPage({super.key, this.existing});

  @override
  State<AddPurchaseOrderPage> createState() => _AddPurchaseOrderPageState();
}

class _AddPurchaseOrderPageState extends State<AddPurchaseOrderPage>
    with UnsavedChangesMixin {
  // ── text controllers ──────────────────────────────────────────────────────
  final _purchaseOrderNumController = TextEditingController();
  final _referenceController = TextEditingController();
  final _shipmentController = TextEditingController();
  final _customerNotesController = TextEditingController();
  final _termsController = TextEditingController();

  // ── dropdown / selector state ─────────────────────────────────────────────
  String? _vendorName;
  String _transactionSeries = 'Default Transaction Series';
  String _currency = 'INR- Indian Rupee';
  String _location = 'warehouse1';
  String _paymentTerms = 'Due on Receipt';
  _DeliverTo _deliverTo = _DeliverTo.warehouse;

  // ── dates ─────────────────────────────────────────────────────────────────
  DateTime _orderDate = DateTime.now();
  DateTime? _expectedDeliveryDate;

  // ── line items & attachments ───────────────────────────────────────────────
  final List<PurchaseOrderLineItem> _lineItems = [];
  List<AttachmentFile> _attachments = [];

  bool _isLoading = true;

  // ── static option lists ───────────────────────────────────────────────────
  static const List<String> _vendors = [
    'Global Supplies',
    'Metro Traders',
    'Al Noor Co',
    'Prime Distributors',
  ];

  static const List<String> _transactionSeriesOptions = [
    'Default Transaction Series',
    'Series A',
    'Series B',
  ];

  static const List<String> _currencyOptions = [
    'INR- Indian Rupee',
    'USD- US Dollar',
    'EUR- Euro',
    'GBP- British Pound',
  ];

  static const List<String> _locationOptions = [
    'warehouse1',
    'warehouse2',
    'warehouse3',
  ];

  static const List<String> _paymentTermsOptions = [
    'Due on Receipt',
    'Net 15',
    'Net 30',
    'Net 45',
    'Net 60',
  ];

  // ── lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _purchaseOrderNumController.text = 'PO-00015';
    if (widget.existing != null) {
      final o = widget.existing!;
      _purchaseOrderNumController.text = o.purchaseOrderNumber;
      _referenceController.text = o.referenceNumber;
      _vendorName = o.vendorName.isEmpty ? null : o.vendorName;
      _orderDate = o.orderDate;
      _expectedDeliveryDate = o.expectedDeliveryDate;
      _customerNotesController.text = o.customerNotes;
      _termsController.text = o.termsAndConditions;
      _lineItems.addAll(o.lineItems);
    }
    _purchaseOrderNumController.addListener(markDirty);
    _referenceController.addListener(markDirty);
    _shipmentController.addListener(markDirty);
    _customerNotesController.addListener(markDirty);
    _termsController.addListener(markDirty);
    _load();
  }

  @override
  void dispose() {
    _purchaseOrderNumController.removeListener(markDirty);
    _referenceController.removeListener(markDirty);
    _shipmentController.removeListener(markDirty);
    _customerNotesController.removeListener(markDirty);
    _termsController.removeListener(markDirty);
    _purchaseOrderNumController.dispose();
    _referenceController.dispose();
    _shipmentController.dispose();
    _customerNotesController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  // ── date picker ───────────────────────────────────────────────────────────
  Future<void> _pickDate({required bool isDeliveryDate}) async {
    final initialDate = isDeliveryDate
        ? (_expectedDeliveryDate ?? _orderDate.add(const Duration(days: 7)))
        : _orderDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isDeliveryDate) {
          _expectedDeliveryDate = picked;
        } else {
          _orderDate = picked;
        }
      });
      markDirty();
    }
  }

  // ── bottom-sheet selectors ────────────────────────────────────────────────
  Future<void> _selectVendor() async {
    final selected = await _showPickerSheet<String>(
      title: 'Vendor Name',
      options: _vendors,
      current: _vendorName,
      labelBuilder: (v) => v,
    );
    if (selected != null) setState(() => _vendorName = selected);
  }

  Future<void> _selectTransactionSeries() async {
    final selected = await _showPickerSheet<String>(
      title: 'Transaction Series',
      options: _transactionSeriesOptions,
      current: _transactionSeries,
      labelBuilder: (v) => v,
    );
    if (selected != null) setState(() => _transactionSeries = selected);
  }

  Future<void> _selectCurrency() async {
    final selected = await _showPickerSheet<String>(
      title: 'Purchase Order Currency',
      options: _currencyOptions,
      current: _currency,
      labelBuilder: (v) => v,
    );
    if (selected != null) setState(() => _currency = selected);
  }

  Future<void> _selectLocation() async {
    final selected = await _showPickerSheet<String>(
      title: 'Location',
      options: _locationOptions,
      current: _location,
      labelBuilder: (v) => v,
    );
    if (selected != null) setState(() => _location = selected);
  }

  Future<void> _selectPaymentTerms() async {
    final selected = await _showPickerSheet<String>(
      title: 'Payment Terms',
      options: _paymentTermsOptions,
      current: _paymentTerms,
      labelBuilder: (v) => v,
    );
    if (selected != null) setState(() => _paymentTerms = selected);
  }

  /// Generic picker bottom sheet — returns the chosen value or null.
  Future<T?> _showPickerSheet<T>({
    required String title,
    required List<T> options,
    required T? current,
    required String Function(T) labelBuilder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.colors.card,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height10,
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 1.05,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: options
                    .map(
                      (opt) => ListTile(
                        title: Text(
                          labelBuilder(opt),
                          style: TextStyle(
                            color: opt == current
                                ? AppColors.primary
                                : context.colors.textPrimary,
                            fontWeight: opt == current
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: opt == current
                            ? Icon(
                                Icons.check_rounded,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(ctx, opt),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── line items ────────────────────────────────────────────────────────────
  Future<void> _addLineItem() async {
    final result = await Navigator.push<Object>(
      context,
      MaterialPageRoute(
        builder: (_) => AddLineItemPage<PurchaseOrderLineItem>(
          buildItem: (LineItemFormData data, String? existingId) =>
              PurchaseOrderLineItem(
                id:
                    existingId ??
                    DateTime.now().microsecondsSinceEpoch.toString(),
                itemId: data.itemId,
                itemName: data.itemName,
                description: data.description,
                quantity: data.quantity,
                rate: data.rate,
                discount: data.discount,
                discountIsPercent: data.discountIsPercent,
                taxRate: data.taxRate,
              ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    if (result is PurchaseOrderLineItem) {
      setState(() => _lineItems.add(result));
      markDirty();
    } else if (result is List<PurchaseOrderLineItem> && result.isNotEmpty) {
      setState(() => _lineItems.add(result.first));
      markDirty();
      await _addLineItem();
    }
  }

  // ── computed totals ───────────────────────────────────────────────────────
  double get _subTotal => _lineItems.fold(0.0, (sum, item) => sum + item.net);
  double get _totalTax =>
      _lineItems.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get _grandTotal => _subTotal + _totalTax;

  // ── save ──────────────────────────────────────────────────────────────────
  void _savePurchaseOrder({
    PurchaseOrderStatus status = PurchaseOrderStatus.draft,
  }) {
    if (_vendorName == null || _vendorName!.trim().isEmpty) {
      ToastificationHelper.showWarning(context, 'Please select a Vendor.');
      return;
    }
    if (_purchaseOrderNumController.text.trim().isEmpty) {
      ToastificationHelper.showWarning(
        context,
        'Please enter a Purchase Order Number.',
      );
      return;
    }

    final newOrder = PurchaseOrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      purchaseOrderNumber: _purchaseOrderNumController.text.trim(),
      vendorName: _vendorName!.trim(),
      referenceNumber: _referenceController.text.trim(),
      orderDate: _orderDate,
      expectedDeliveryDate: _expectedDeliveryDate,
      status: status,
      lineItems: List.unmodifiable(_lineItems),
      total: _grandTotal,
      customerNotes: _customerNotesController.text.trim(),
      termsAndConditions: _termsController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    markClean();
    Navigator.pop(context, newOrder);
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: CustomBackAppBar(
          title: widget.existing == null
              ? 'New Purchase Order'
              : 'Edit Purchase Order',
          backgroundColor: context.colors.card,
          onLeadingPressed: () => onPopInvokedWithResult(false, null),
          actions: [
            TextButton(
              onPressed: () =>
                  _savePurchaseOrder(status: PurchaseOrderStatus.draft),
              child: Text(
                'SAVE AS DRAFT',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: Dimensions.font16 * 0.75,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: context.colors.textPrimary,
              ),
              onSelected: (val) {
                if (val == 'save_issued') {
                  _savePurchaseOrder(status: PurchaseOrderStatus.issued);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'save_issued',
                  child: Text('Save as Issued'),
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const FormPageSkeleton()
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  Dimensions.width15,
                  Dimensions.height15,
                  Dimensions.width15,
                  Dimensions.height30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Card 1: Vendor + identifiers ──────────────────────
                    FormCard(
                      children: [
                        // Vendor Name
                        const RequiredLabel(text: 'Vendor Name'),
                        SizedBox(height: Dimensions.height10 / 2),
                        _selectorField(
                          value: _vendorName,
                          hint: 'Start typing to select a Vendor',
                          onTap: _selectVendor,
                          trailingIcon: Icons.add_rounded,
                        ),
                        SizedBox(height: Dimensions.height20),

                        // Purchase Order Currency
                        Text(
                          'Purchase Order Currency',
                          style: FormTextStyles.label(),
                        ),
                        SizedBox(height: Dimensions.height10 / 2),
                        _selectorField(
                          value: _currency,
                          hint: 'Select currency',
                          onTap: _selectCurrency,
                        ),
                        SizedBox(height: Dimensions.height20),

                        // Location
                        Text('Location', style: FormTextStyles.label()),
                        SizedBox(height: Dimensions.height10 / 2),
                        _selectorField(
                          value: _location,
                          hint: 'Select location',
                          onTap: _selectLocation,
                        ),
                        SizedBox(height: Dimensions.height20),

                        // Deliver To
                        const RequiredLabel(text: 'Deliver To'),
                        SizedBox(height: Dimensions.height10),
                        Row(
                          children: [
                            _radioOption(
                              label: 'Warehouse\nLocation',
                              value: _DeliverTo.warehouse,
                            ),
                            SizedBox(width: Dimensions.width20),
                            _radioOption(
                              label: 'Customer',
                              value: _DeliverTo.customer,
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.height10),
                        // Deliver-to sub-selector
                        _selectorField(
                          value: _deliverTo == _DeliverTo.warehouse
                              ? _location
                              : null,
                          hint: _deliverTo == _DeliverTo.warehouse
                              ? _location
                              : 'Select customer',
                          onTap: _deliverTo == _DeliverTo.warehouse
                              ? _selectLocation
                              : () {},
                        ),
                        if (_deliverTo == _DeliverTo.warehouse) ...[
                          SizedBox(height: Dimensions.height10 / 2),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Delivery address',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.82,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: Dimensions.height20),

                        // Transaction Series
                        Text(
                          'Transaction Series',
                          style: FormTextStyles.label(),
                        ),
                        SizedBox(height: Dimensions.height10 / 2),
                        _selectorField(
                          value: _transactionSeries,
                          hint: 'Select series',
                          onTap: _selectTransactionSeries,
                        ),
                        SizedBox(height: Dimensions.height20),

                        // Purchase Order#
                        const RequiredLabel(text: 'Purchase Order#'),
                        SizedBox(height: Dimensions.height10 / 2),
                        _textFieldWithSuffix(
                          controller: _purchaseOrderNumController,
                          suffix: Icon(
                            Icons.settings_outlined,
                            size: Dimensions.iconSize24 * 0.85,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),

                        // Reference#
                        Text('Reference#', style: FormTextStyles.label()),
                        SizedBox(height: Dimensions.height10 / 2),
                        TextField(
                          controller: _referenceController,
                          style: FormTextStyles.value(context),
                          decoration: _underlineDecoration(),
                        ),
                        SizedBox(height: Dimensions.height20),

                        // Date
                        const RequiredLabel(text: 'Date'),
                        SizedBox(height: Dimensions.height10 / 2),
                        _dateField(
                          formatDate(_orderDate),
                          () => _pickDate(isDeliveryDate: false),
                        ),
                        SizedBox(height: Dimensions.height20),

                        // Expected Delivery Date
                        Text(
                          'Expected Delivery Date',
                          style: FormTextStyles.label(),
                        ),
                        SizedBox(height: Dimensions.height10 / 2),
                        _dateField(
                          _expectedDeliveryDate != null
                              ? formatDate(_expectedDeliveryDate!)
                              : 'dd/MM/yyyy',
                          () => _pickDate(isDeliveryDate: true),
                          isPlaceholder: _expectedDeliveryDate == null,
                        ),
                        SizedBox(height: Dimensions.height20),

                        // Payment Terms
                        Text('Payment Terms', style: FormTextStyles.label()),
                        SizedBox(height: Dimensions.height10 / 2),
                        _selectorField(
                          value: _paymentTerms,
                          hint: 'Select payment terms',
                          onTap: _selectPaymentTerms,
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height15),

                    // ── Card 2: Shipment Preference ───────────────────────
                    FormCard(
                      children: [
                        Text(
                          'Shipment preference',
                          style: FormTextStyles.label(),
                        ),
                        SizedBox(height: Dimensions.height10 / 2),
                        TextField(
                          controller: _shipmentController,
                          style: FormTextStyles.value(context),
                          decoration: _underlineDecoration(
                            hint: 'Select or Type to add',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height15),

                    // ── Card 3: Line Items ────────────────────────────────
                    FormCard(
                      children: [
                        // Existing line item cards
                        ..._lineItems.asMap().entries.map(
                          (e) => _lineItemCard(e.key, e.value),
                        ),

                        // Add Line Item button
                        GestureDetector(
                          onTap: _addLineItem,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height20,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.card,
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius15,
                              ),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle,
                                  color: AppColors.primary,
                                  size: Dimensions.iconSize24,
                                ),
                                SizedBox(width: Dimensions.width10),
                                Text(
                                  'Add Line Item',
                                  style: TextStyle(
                                    fontSize: Dimensions.font16 * 0.9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Totals summary (only when line items exist)
                        if (_lineItems.isNotEmpty) ...[
                          SizedBox(height: Dimensions.height20),
                          Container(
                            padding: EdgeInsets.all(Dimensions.width15),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius15,
                              ),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                _totalRow('Sub Total', _subTotal),
                                _totalRow('Tax', _totalTax),
                                const FormDivider(),
                                _totalRow('Total', _grandTotal, bold: true),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: Dimensions.height15),

                    // ── Card 4: Notes & Terms ─────────────────────────────
                    FormCard(
                      children: [
                        Text('Customer Notes', style: FormTextStyles.label()),
                        SizedBox(height: Dimensions.height10 / 2),
                        TextField(
                          controller: _customerNotesController,
                          style: FormTextStyles.value(context),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: _underlineDecoration(),
                        ),
                        SizedBox(height: Dimensions.height20),

                        Text(
                          'Terms & Conditions',
                          style: FormTextStyles.label(),
                        ),
                        SizedBox(height: Dimensions.height10 / 2),
                        TextField(
                          controller: _termsController,
                          style: FormTextStyles.value(context),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: _underlineDecoration(),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height15),

                    // ── Card 5: Attachments ───────────────────────────────
                    FormCard(
                      children: [
                        Text('Attachments', style: FormTextStyles.label()),
                        SizedBox(height: Dimensions.height15),
                        AttachmentPicker(
                          label: 'Upload File',
                          maxFiles: 10,
                          initialFiles: _attachments,
                          onChanged: (files) =>
                              setState(() => _attachments = files),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ── helper widgets ─────────────────────────────────────────────────────────

  Widget _radioOption({required String label, required _DeliverTo value}) {
    final isSelected = _deliverTo == value;
    return GestureDetector(
      onTap: () {
        setState(() => _deliverTo = value);
        markDirty();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Dimensions.iconSize24,
            height: Dimensions.iconSize24,
            margin: EdgeInsets.only(top: Dimensions.height10 / 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : context.colors.border,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: Dimensions.iconSize24 / 2,
                      height: Dimensions.iconSize24 / 2,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: Dimensions.width10 / 2),
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? context.colors.textPrimary
                  : context.colors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineItemCard(int index, PurchaseOrderLineItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height10),
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: context.colors.surfaceLight,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          ItemThumbnail(size: Dimensions.height45 * 0.8),
          SizedBox(width: Dimensions.width10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.85,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: Dimensions.height10 / 4),
                Text(
                  '${item.quantity.toStringAsFixed(2)} × ₹${item.rate.toStringAsFixed(2)}  •  ₹${item.net.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.68,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: Dimensions.iconSize24 - 6,
              color: context.colors.textTertiary,
            ),
            onPressed: () {
              setState(() => _lineItems.removeAt(index));
              markDirty();
            },
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height10 / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.82,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: bold
                  ? context.colors.textPrimary
                  : context.colors.textSecondary,
            ),
          ),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: Dimensions.font16 * (bold ? 0.95 : 0.82),
              fontWeight: FontWeight.w700,
              color: bold ? AppColors.primary : context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _underlineDecoration({String? hint}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: TextStyle(
        color: context.colors.textTertiary,
        fontSize: Dimensions.font16 * 0.9,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: Dimensions.height10),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: context.colors.border),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: context.colors.border),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _textFieldWithSuffix({
    required TextEditingController controller,
    required Widget suffix,
  }) {
    return TextField(
      controller: controller,
      style: FormTextStyles.value(context),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: Dimensions.height10),
        suffixIcon: suffix,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: context.colors.border),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _selectorField({
    required String? value,
    required String hint,
    required VoidCallback onTap,
    IconData trailingIcon = Icons.arrow_drop_down_rounded,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.colors.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.9,
                  color: value == null
                      ? context.colors.textTertiary
                      : context.colors.textPrimary,
                  fontWeight: value == null
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            Icon(
              trailingIcon,
              size: Dimensions.iconSize24,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(
    String text,
    VoidCallback onTap, {
    bool isPlaceholder = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.colors.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.9,
                color: isPlaceholder
                    ? context.colors.textTertiary
                    : context.colors.textPrimary,
                fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: Dimensions.iconSize24 * 0.85,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
