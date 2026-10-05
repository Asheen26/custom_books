import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/line_item_form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/customers/controllers/customers_list_controller.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:custom_books/features/delivery_challans/controllers/delivery_challan_form_controller.dart';
import 'package:custom_books/features/delivery_challans/models/delivery_challan_model.dart';
import 'package:custom_books/features/delivery_challans/views/add_delivery_challan_line_item_page.dart';
import 'package:custom_books/features/inventory_adjustments/widgets/adjustment_form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:custom_books/core/utils/date_formatter.dart';

class AddDeliveryChallanPage extends StatefulWidget {
  final DeliveryChallanModel? existing;

  const AddDeliveryChallanPage({super.key, this.existing});

  @override
  State<AddDeliveryChallanPage> createState() => _AddDeliveryChallanPageState();
}

class _AddDeliveryChallanPageState extends State<AddDeliveryChallanPage>
    with UnsavedChangesMixin {
  final _formController = DeliveryChallanFormController();
  final _customersController = CustomersListController();

  final _customerController = TextEditingController();
  final _challanNumController = TextEditingController();
  final _referenceController = TextEditingController();

  String? _selectedCustomerId;

  final List<DeliveryChallanLineItem> _lineItems = [];
  DateTime _challanDate = DateTime.now();
  String _type = 'Job Work';
  bool _isLoading = true;

  static const List<String> _typeOptions = [
    'Job Work',
    'Supply on Approval',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _formController.addListener(_onFormChanged);
    _load();
    if (widget.existing != null) {
      final c = widget.existing!;
      _challanNumController.text = c.challanNumber;
      _customerController.text = c.customerName;
      _referenceController.text = c.referenceNumber;
      _lineItems.addAll(c.lineItems);
      _challanDate = c.challanDate;
      _type = c.type;
    }
    _customerController.addListener(markDirty);
    _challanNumController.addListener(markDirty);
    _referenceController.addListener(markDirty);
  }

  @override
  void dispose() {
    _formController.removeListener(_onFormChanged);
    _formController.dispose();
    _customersController.dispose();
    _customerController.removeListener(markDirty);
    _challanNumController.removeListener(markDirty);
    _referenceController.removeListener(markDirty);
    _customerController.dispose();
    _challanNumController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _challanDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _challanDate = picked);
      markDirty();
    }
  }

  Future<void> _selectCustomer() async {
    await _customersController.loadFirstPage();

    if (!mounted) return;

    final selected = await showModalBottomSheet<CustomerModel>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.colors.card,
      builder: (sheetCtx) =>
          _CustomerPickerSheet(controller: _customersController),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedCustomerId = selected.id;
        _customerController.text = selected.displayName ?? selected.name;
      });
      markDirty();
    }
  }

  Future<void> _selectType() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.colors.card,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(Dimensions.width15),
              child: Text(
                'Type',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 1.1,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            ..._typeOptions.map(
              (type) => ListTile(
                title: Text(
                  type,
                  style: TextStyle(
                    color: type == _type
                        ? AppColors.primary
                        : context.colors.textPrimary,
                    fontWeight: type == _type
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: type == _type
                    ? Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, type),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() => _type = selected);
      markDirty();
    }
  }

  Future<void> _addLineItem() async {
    final result = await Navigator.push<Object>(
      context,
      MaterialPageRoute(builder: (_) => const AddDeliveryChallanLineItemPage()),
    );
    if (!mounted || result == null) return;
    if (result is DeliveryChallanLineItem) {
      setState(() => _lineItems.add(result));
    } else if (result is List<DeliveryChallanLineItem> && result.isNotEmpty) {
      setState(() => _lineItems.add(result.first));
      await _addLineItem();
    }
  }

  Future<void> _saveChallan({
    DeliveryChallanStatus status = DeliveryChallanStatus.draft,
  }) async {
    if (_selectedCustomerId == null ||
        _customerController.text.trim().isEmpty) {
      ToastificationHelper.showWarning(context, 'Please select a Customer.');
      return;
    }
    if (_lineItems.isEmpty) {
      ToastificationHelper.showWarning(
        context,
        'Please add at least one line item.',
      );
      return;
    }

    final result = await _formController.create(
      customerId: _selectedCustomerId!,
      referenceNumber: _referenceController.text.trim(),
      challanDate: _challanDate,
      type: _type,
      lineItems: _lineItems,
      status: status,
    );

    if (!mounted) return;

    if (result != null) {
      markClean();
      Navigator.pop(context, result);
    } else {
      ToastificationHelper.showError(
        context,
        _formController.errorMessage ??
            'Could not save delivery challan. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = _formController.isSubmitting;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: context.colors.background,
            appBar: CustomBackAppBar(
              title: widget.existing == null
                  ? 'New Delivery Challan'
                  : 'Edit Delivery Challan',
              backgroundColor: context.colors.card,
              onLeadingPressed: () => onPopInvokedWithResult(false, null),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => _saveChallan(status: DeliveryChallanStatus.draft),
                  child: Text(
                    'SAVE AS DRAFT',
                    style: TextStyle(
                      color: isSubmitting
                          ? context.colors.textTertiary
                          : AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: Dimensions.font16 * 0.75,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  enabled: !isSubmitting,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: context.colors.textPrimary,
                  ),
                  onSelected: (val) {
                    if (val == 'save_delivered') {
                      _saveChallan(status: DeliveryChallanStatus.delivered);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'save_delivered',
                      child: Text('Save as Delivered'),
                    ),
                  ],
                ),
              ],
            ),
            body: _isLoading
                ? const FormPageSkeleton()
                : SingleChildScrollView(
                    padding: EdgeInsets.all(Dimensions.width15),
                    child: Column(
                      children: [
                        FormCard(
                          children: [
                            const RequiredLabel(text: 'Customer Name'),
                            SizedBox(height: Dimensions.height10 / 2),
                            InkWell(
                              onTap: isSubmitting ? null : _selectCustomer,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.width10 / 2,
                                  vertical: Dimensions.height10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: context.colors.border,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _customerController.text.isEmpty
                                            ? 'Start typing to select a Customer'
                                            : _customerController.text,
                                        style: TextStyle(
                                          fontSize: Dimensions.font16 * 0.9,
                                          color:
                                              _customerController.text.isEmpty
                                              ? context.colors.textTertiary
                                              : context.colors.textPrimary,
                                          fontWeight:
                                              _customerController.text.isEmpty
                                              ? FontWeight.normal
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.add_rounded,
                                      size: Dimensions.iconSize24,
                                      color: context.colors.textPrimary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: Dimensions.height20),

                            Text('Reference#', style: FormTextStyles.label()),
                            SizedBox(height: Dimensions.height10 / 2),
                            TextField(
                              controller: _referenceController,
                              enabled: !isSubmitting,
                              style: FormTextStyles.value(context),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: Dimensions.height10,
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: context.colors.border,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: context.colors.border,
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: Dimensions.height20),

                            const RequiredLabel(text: 'Challan Date'),
                            SizedBox(height: Dimensions.height10 / 2),
                            InkWell(
                              onTap: isSubmitting ? null : _pickDate,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: Dimensions.height10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: context.colors.border,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatDate(_challanDate),
                                      style: FormTextStyles.value(context),
                                    ),
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: Dimensions.iconSize24 * 0.85,
                                      color: context.colors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: Dimensions.height20),

                            Text('Type', style: FormTextStyles.label()),
                            SizedBox(height: Dimensions.height10 / 2),
                            InkWell(
                              onTap: isSubmitting ? null : _selectType,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: Dimensions.height10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: context.colors.border,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _type,
                                      style: FormTextStyles.value(context),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_rounded,
                                      size: Dimensions.iconSize24,
                                      color: context.colors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.height15),

                        FormCard(
                          children: [
                            ..._lineItems.asMap().entries.map(
                              (entry) => _lineItemCard(entry.key, entry.value),
                            ),
                            AddLineItemButton(
                              onPressed: isSubmitting ? () {} : _addLineItem,
                            ),
                            if (_lineItems.isNotEmpty) ...[
                              SizedBox(height: Dimensions.height20),
                              Container(
                                padding: EdgeInsets.all(Dimensions.width15),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.05,
                                  ),
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
                                    _totalRow(
                                      'Sub Total',
                                      _lineItems.fold<double>(
                                        0,
                                        (s, i) => s + i.net,
                                      ),
                                    ),
                                    _totalRow(
                                      'Tax',
                                      _lineItems.fold<double>(
                                        0,
                                        (s, i) => s + i.taxAmount,
                                      ),
                                    ),
                                    const FormDivider(),
                                    _totalRow(
                                      'Total',
                                      _lineItems.fold<double>(
                                        0,
                                        (s, i) => s + i.net + i.taxAmount,
                                      ),
                                      bold: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
          ),

          if (isSubmitting)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _lineItemCard(int index, DeliveryChallanLineItem item) {
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
            onPressed: _formController.isSubmitting
                ? null
                : () => setState(() => _lineItems.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) => Padding(
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

// ---------------------------------------------------------------------------

class _CustomerPickerSheet extends StatefulWidget {
  final CustomersListController controller;

  const _CustomerPickerSheet({required this.controller});

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _onSearchChanged(String query) {
    widget.controller.loadFirstPage(search: query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final customers = widget.controller.customers;
    final isLoading = widget.controller.isLoading;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height10,
              Dimensions.width20,
              Dimensions.height10,
            ),
            child: Text(
              'Select Customer',
              style: TextStyle(
                fontSize: Dimensions.font16 * 1.1,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search customers…',
                hintStyle: TextStyle(color: context.colors.textTertiary),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: context.colors.textSecondary,
                ),
                filled: true,
                fillColor: context.colors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: Dimensions.height10,
                ),
              ),
            ),
          ),
          SizedBox(height: Dimensions.height10),
          const Divider(height: 1),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : customers.isEmpty
                ? Center(
                    child: Text(
                      'No customers found',
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final c = customers[index];
                      final displayName = c.displayName ?? c.name;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            displayName.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          displayName,
                          style: TextStyle(color: context.colors.textPrimary),
                        ),
                        subtitle: c.email != null && c.email!.isNotEmpty
                            ? Text(
                                c.email!,
                                style: TextStyle(
                                  color: context.colors.textSecondary,
                                  fontSize: Dimensions.font16 * 0.75,
                                ),
                              )
                            : null,
                        onTap: () => Navigator.pop(context, c),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
