import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/line_item_form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/credit_notes/models/credit_note_model.dart';
import 'package:custom_books/core/line_item/add_line_item_page.dart';
import 'package:custom_books/core/line_item/item_lookup_model.dart';
import 'package:custom_books/features/inventory_adjustments/widgets/adjustment_form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:custom_books/core/utils/date_formatter.dart';

class AddCreditNotePage extends StatefulWidget {
  final CreditNoteModel? existing;

  const AddCreditNotePage({super.key, this.existing});

  @override
  State<AddCreditNotePage> createState() => _AddCreditNotePageState();
}

class _AddCreditNotePageState extends State<AddCreditNotePage>
    with UnsavedChangesMixin {
  final _customerController = TextEditingController();
  final _creditNoteNumController = TextEditingController();
  final _referenceController = TextEditingController();

  final List<CreditNoteLineItem> _lineItems = [];
  DateTime _creditNoteDate = DateTime.now();
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
    if (widget.existing != null) {
      final n = widget.existing!;
      _creditNoteNumController.text = n.creditNoteNumber;
      _customerController.text = n.customerName;
      _referenceController.text = n.referenceNumber;
      _lineItems.addAll(n.lineItems);
      _creditNoteDate = n.creditNoteDate;
    } else {
      _creditNoteNumController.text = 'CN-00016';
    }
    _customerController.addListener(markDirty);
    _creditNoteNumController.addListener(markDirty);
    _referenceController.addListener(markDirty);
  }

  @override
  void dispose() {
    _customerController.removeListener(markDirty);
    _creditNoteNumController.removeListener(markDirty);
    _referenceController.removeListener(markDirty);
    _customerController.dispose();
    _creditNoteNumController.dispose();
    _referenceController.dispose();
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
      initialDate: _creditNoteDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _creditNoteDate = picked);
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
    }
  }

  Future<void> _addLineItem() async {
    final result = await Navigator.push<Object>(
      context,
      MaterialPageRoute(
        builder: (_) => AddLineItemPage<CreditNoteLineItem>(
          buildItem: (LineItemFormData data, String? existingId) =>
              CreditNoteLineItem(
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
    if (result is CreditNoteLineItem) {
      setState(() => _lineItems.add(result));
    } else if (result is List<CreditNoteLineItem> && result.isNotEmpty) {
      setState(() => _lineItems.add(result.first));
      await _addLineItem();
    }
  }

  void _saveNote({CreditNoteStatus status = CreditNoteStatus.draft}) {
    if (_customerController.text.trim().isEmpty) {
      ToastificationHelper.showWarning(context, 'Please select a Customer.');
      return;
    }
    if (_creditNoteNumController.text.trim().isEmpty) {
      ToastificationHelper.showWarning(
        context,
        'Please enter a Credit Note Number.',
      );
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

    final newNote = CreditNoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      creditNoteNumber: _creditNoteNumController.text.trim(),
      customerName: _customerController.text.trim(),
      referenceNumber: _referenceController.text.trim(),
      creditNoteDate: _creditNoteDate,
      status: status,
      lineItems: List.from(_lineItems),
      total: total,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    markClean();
    Navigator.pop(context, newNote);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: CustomBackAppBar(
          title: widget.existing == null
              ? 'New Credit Note'
              : 'Edit Credit Note',
          backgroundColor: context.colors.card,
          onLeadingPressed: () => onPopInvokedWithResult(false, null),
          actions: [
            TextButton(
              onPressed: () => _saveNote(status: CreditNoteStatus.draft),
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
                if (val == 'save_open') {
                  _saveNote(status: CreditNoteStatus.open);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'save_open',
                  child: Text('Save as Open'),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _customerController.text.isEmpty
                                        ? 'Start typing to select a Customer'
                                        : _customerController.text,
                                    style: TextStyle(
                                      fontSize: Dimensions.font16 * 0.9,
                                      color: _customerController.text.isEmpty
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

                        // Credit Note# *
                        const RequiredLabel(text: 'Credit Note#'),
                        SizedBox(height: Dimensions.height10 / 2),
                        TextField(
                          controller: _creditNoteNumController,
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
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),

                        // Reference#
                        Text('Reference#', style: FormTextStyles.label()),
                        SizedBox(height: Dimensions.height10 / 2),
                        TextField(
                          controller: _referenceController,
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
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),

                        // Credit Note Date *
                        const RequiredLabel(text: 'Credit Note Date'),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatDate(_creditNoteDate),
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
                          (entry) => _lineItemCard(entry.key, entry.value),
                        ),
                        AddLineItemButton(onPressed: _addLineItem),
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
    );
  }

  Widget _lineItemCard(int index, CreditNoteLineItem item) {
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
