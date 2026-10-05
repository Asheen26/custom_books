import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/bottom_sheet_drag_handle.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/line_item_form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/inventory_adjustments/widgets/adjustment_form_widgets.dart';
import 'package:custom_books/features/recurring_invoices/models/recurring_invoice_model.dart';
import 'package:custom_books/features/recurring_invoices/views/add_recurring_invoice_line_item_page.dart';
import 'package:flutter/material.dart';

class AddRecurringInvoicePage extends StatefulWidget {
  final RecurringInvoiceModel? existing;

  const AddRecurringInvoicePage({super.key, this.existing});

  @override
  State<AddRecurringInvoicePage> createState() =>
      _AddRecurringInvoicePageState();
}

class _AddRecurringInvoicePageState extends State<AddRecurringInvoicePage>
    with UnsavedChangesMixin {
  final _profileNameController = TextEditingController();
  final _customerController = TextEditingController();

  final List<RecurringInvoiceLineItem> _lineItems = [];
  DateTime _startDate = DateTime.now();
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  bool _isLoading = true;

  static const List<String> _customers = [
    'Nandhu',
    'Parthiv Ajith',
    'Amal',
    'Nabeel',
    'Tech Geum',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    final existing = widget.existing;
    if (existing != null) {
      _profileNameController.text = existing.profileName;
      _customerController.text = existing.customerName;
      _lineItems.addAll(existing.lineItems);
      _startDate = existing.startDate;
      _frequency = existing.frequency;
    }
    _profileNameController.addListener(markDirty);
    _customerController.addListener(markDirty);
  }

  @override
  void dispose() {
    _profileNameController.removeListener(markDirty);
    _customerController.removeListener(markDirty);
    _profileNameController.dispose();
    _customerController.dispose();
    super.dispose();
  }

  /// Simulates preparing the form so the shimmer skeleton is shown briefly.
  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
      markDirty();
    }
  }

  Future<void> _selectCustomer() async {
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
                'Select Customer',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 1.1,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ..._customers.map(
                    (name) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(color: context.colors.textPrimary),
                      ),
                      onTap: () => Navigator.pop(context, name),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() => _customerController.text = selected);
      markDirty();
    }
  }

  Future<void> _selectFrequency() async {
    final selected = await showModalBottomSheet<RecurringFrequency>(
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
                'Frequency',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 1.1,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            ...RecurringFrequency.values.map(
              (freq) => ListTile(
                title: Text(
                  freq.label,
                  style: TextStyle(
                    color: freq == _frequency
                        ? AppColors.primary
                        : context.colors.textPrimary,
                    fontWeight: freq == _frequency
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: freq == _frequency
                    ? Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, freq),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() => _frequency = selected);
      markDirty();
    }
  }

  Future<void> _addLineItem() async {
    final result = await Navigator.push<Object>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddRecurringInvoiceLineItemPage(),
      ),
    );
    if (!mounted || result == null) return;
    if (result is RecurringInvoiceLineItem) {
      setState(() => _lineItems.add(result));
    } else if (result is List<RecurringInvoiceLineItem> && result.isNotEmpty) {
      setState(() => _lineItems.add(result.first));
      await _addLineItem();
    }
  }

  void _saveProfile({
    RecurringInvoiceStatus status = RecurringInvoiceStatus.active,
  }) {
    if (_profileNameController.text.trim().isEmpty) {
      ToastificationHelper.showWarning(context, 'Please enter a Profile Name.');
      return;
    }
    if (_customerController.text.trim().isEmpty) {
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

    final total = _lineItems.fold<double>(0, (s, i) => s + i.net + i.taxAmount);

    final newProfile = RecurringInvoiceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      profileName: _profileNameController.text.trim(),
      customerName: _customerController.text.trim(),
      frequency: _frequency,
      startDate: _startDate,
      status: status,
      lineItems: List.from(_lineItems),
      amount: total,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    markClean();
    Navigator.pop(context, newProfile);
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
                      title: widget.existing == null
                          ? 'New Recurring Invoice'
                          : 'Edit Recurring Invoice',
                      leadingType: AppBarLeadingType.back,
                      onLeadingPressed: () =>
                          onPopInvokedWithResult(false, null),
                      actions: [
                        AppBarElevatedButton(
                          label: 'SAVE',
                          onPressed: () => _saveProfile(
                            status: RecurringInvoiceStatus.active,
                          ),
                        ),
                        SizedBox(width: Dimensions.width10),
                        AppBarIconButton(
                          icon: Icons.more_vert_rounded,
                          color: AppColors.accent,
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => Container(
                                decoration: BoxDecoration(
                                  color: context.colors.card,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                      Dimensions.radius20 * 1.2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const BottomSheetDragHandle(),
                                    ListTile(
                                      leading: Icon(
                                        Icons.drafts_rounded,
                                        color: AppColors.primary,
                                      ),
                                      title: Text(
                                        'Save as Draft',
                                        style: TextStyle(
                                          fontSize: Dimensions.font16 * 0.9,
                                          fontWeight: FontWeight.w600,
                                          color: context.colors.textPrimary,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _saveProfile(
                                          status: RecurringInvoiceStatus.draft,
                                        );
                                      },
                                    ),
                                    SizedBox(height: Dimensions.height20),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: Dimensions.width20),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(Dimensions.width15),
                        child: Column(
                          children: [
                            FormCard(
                              children: [
                                // Profile Name *
                                const RequiredLabel(text: 'Profile Name'),
                                SizedBox(height: Dimensions.height10 / 2),
                                TextField(
                                  controller: _profileNameController,
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

                                // Customer Name *
                                const RequiredLabel(text: 'Customer Name'),
                                SizedBox(height: Dimensions.height10 / 2),
                                InkWell(
                                  onTap: _selectCustomer,
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
                                                  _customerController
                                                      .text
                                                      .isEmpty
                                                  ? context.colors.textTertiary
                                                  : context.colors.textPrimary,
                                              fontWeight:
                                                  _customerController
                                                      .text
                                                      .isEmpty
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

                                // Frequency
                                Text(
                                  'Frequency',
                                  style: FormTextStyles.label(),
                                ),
                                SizedBox(height: Dimensions.height10 / 2),
                                InkWell(
                                  onTap: _selectFrequency,
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
                                          _frequency.label,
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
                                SizedBox(height: Dimensions.height20),

                                // Start Date *
                                const RequiredLabel(text: 'Start Date'),
                                SizedBox(height: Dimensions.height10 / 2),
                                InkWell(
                                  onTap: _pickDate,
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
                                          formatDate(_startDate),
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
                              ],
                            ),
                            SizedBox(height: Dimensions.height15),

                            // Card 2: Line Items
                            FormCard(
                              children: [
                                ..._lineItems.asMap().entries.map(
                                  (entry) =>
                                      _lineItemCard(entry.key, entry.value),
                                ),
                                AddLineItemButton(onPressed: _addLineItem),
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
                  ],
                ),
        ),
      ),
    );
  }

  Widget _lineItemCard(int index, RecurringInvoiceLineItem item) {
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
            onPressed: () => setState(() => _lineItems.removeAt(index)),
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
