import 'dart:async';

import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/line_item/item_lookup_controller.dart';
import 'package:custom_books/core/line_item/item_lookup_model.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/line_item_form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:flutter/material.dart';

/// A generic Add / Edit Line Item page shared by invoices, sales orders,
/// recurring invoices, credit notes, and delivery challans.
///
/// The caller provides a [buildItem] callback that converts the common
/// [LineItemFormData] into its own feature-specific model.  The page pops
/// with either:
///  - A single `T` when the user taps **Save**.
///  - A `List<T>` with one real item when the user taps **Save and New**
///    (the caller should add the item then immediately re-open the page).
///
/// Pass [initialData] to enter **edit mode** — all fields are pre-filled and
/// the app-bar title changes to "Edit Line Item".
///
/// Example (invoices):
/// ```dart
/// final result = await Navigator.push<Object>(
///   context,
///   MaterialPageRoute(
///     builder: (_) => AddLineItemPage<InvoiceLineItem>(
///       buildItem: (data, existingId) => InvoiceLineItem(
///         id: existingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
///         itemId: data.itemId,
///         itemName: data.itemName,
///         description: data.description.isEmpty ? null : data.description,
///         quantity: data.quantity,
///         unit: '',
///         rate: data.rate,
///         amount: data.net,
///         discount: data.discount > 0 ? data.discount : null,
///         taxRate: data.taxRate > 0 ? data.taxRate : null,
///         taxAmount: data.taxAmount > 0 ? data.taxAmount : null,
///       ),
///     ),
///   ),
/// );
/// ```
class AddLineItemPage<T> extends StatefulWidget {
  /// Converts the completed form data into the caller's model type.
  /// [existingId] is non-null when editing an existing item.
  final T Function(LineItemFormData data, String? existingId) buildItem;

  /// Pre-fill the form for edit mode.
  final LineItemFormData? initialData;

  /// The existing item's id — passed back to [buildItem] so the caller can
  /// preserve the original id on edit.
  final String? existingId;

  /// Label shown in the appbar and success log.  Defaults to the feature name
  /// inferred from [T], but can be overridden (e.g. 'Invoice').
  final String? featureLabel;

  const AddLineItemPage({
    super.key,
    required this.buildItem,
    this.initialData,
    this.existingId,
    this.featureLabel,
  });

  @override
  State<AddLineItemPage<T>> createState() => _AddLineItemPageState<T>();
}

class _AddLineItemPageState<T> extends State<AddLineItemPage<T>>
    with UnsavedChangesMixin {
  // ── controllers ────────────────────────────────────────────────────────────
  final _item = TextEditingController();
  final _description = TextEditingController();
  final _quantity = TextEditingController(text: '1.00');
  final _rate = TextEditingController(text: '0.00');
  final _discount = TextEditingController();

  // ── state ──────────────────────────────────────────────────────────────────
  ItemLookupResult? _selectedItem;
  bool _discountIsPercent = true;
  double _taxRate = 0;
  bool _isLoading = true;

  // ── lookup ─────────────────────────────────────────────────────────────────
  final ItemLookupController _lookupController = ItemLookupController();
  Timer? _debounce;

  // ── computed ───────────────────────────────────────────────────────────────
  List<ItemLookupResult> get _suggestions {
    if (_item.text.trim().isEmpty || _selectedItem != null) return [];
    return _lookupController.results;
  }

  double get _gross =>
      (double.tryParse(_quantity.text) ?? 0) *
      (double.tryParse(_rate.text) ?? 0);

  double get _discountAmount {
    final d = double.tryParse(_discount.text) ?? 0;
    return _discountIsPercent ? _gross * d / 100 : d;
  }

  double get _net => (_gross - _discountAmount).clamp(0, double.infinity);
  double get _taxAmount => _net * _taxRate / 100;

  // ── lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _lookupController.addListener(_onLookupChanged);

    final initial = widget.initialData;
    if (initial != null) {
      // Edit mode — pre-fill all fields immediately, skip loading delay.
      _selectedItem = ItemLookupResult(
        id: initial.itemId,
        name: initial.itemName,
        stockOnHand: 0,
        imageUrl: initial.imageUrl,
        costPrice: initial.rate,
      );
      _item.text = initial.itemName;
      _description.text = initial.description;
      _quantity.text = initial.quantity.toStringAsFixed(2);
      _rate.text = initial.rate.toStringAsFixed(2);
      if (initial.discount > 0) {
        _discount.text = initial.discount.toStringAsFixed(2);
      }
      _discountIsPercent = initial.discountIsPercent;
      _taxRate = initial.taxRate;
      _isLoading = false;
    } else {
      _load();
    }

    _item.addListener(markDirty);
    _description.addListener(markDirty);
    _quantity.addListener(markDirty);
    _rate.addListener(markDirty);
    _discount.addListener(markDirty);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _lookupController.removeListener(_onLookupChanged);
    _lookupController.dispose();
    _item.removeListener(markDirty);
    _description.removeListener(markDirty);
    _quantity.removeListener(markDirty);
    _rate.removeListener(markDirty);
    _discount.removeListener(markDirty);
    _item.dispose();
    _description.dispose();
    _quantity.dispose();
    _rate.dispose();
    _discount.dispose();
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────────────────
  void _onLookupChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (_selectedItem != null) setState(() => _selectedItem = null);
    final q = value.trim();
    if (q.isEmpty) {
      _lookupController.clear();
      setState(() {});
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _lookupController.search(q);
    });
    setState(() {});
  }

  void _selectItem(ItemLookupResult apiItem) {
    appLog(
      '📦 ${widget.featureLabel ?? T.toString()} item selected: ${apiItem.name}',
      name: 'AddLineItemPage',
    );
    setState(() {
      _selectedItem = apiItem;
      _item.text = apiItem.name;
      if (apiItem.costPrice > 0) {
        _rate.text = apiItem.costPrice.toStringAsFixed(2);
      }
    });
    markDirty();
    FocusScope.of(context).unfocus();
  }

  void _clearItem() {
    _debounce?.cancel();
    setState(() {
      _selectedItem = null;
      _item.clear();
      _rate.text = '0.00';
    });
    _lookupController.clear();
    markDirty();
  }

  LineItemFormData? _validateAndBuild() {
    final name = _item.text.trim();
    final quantity = double.tryParse(_quantity.text) ?? 0;
    final rate = double.tryParse(_rate.text) ?? -1;

    if (_selectedItem == null || name.isEmpty || quantity <= 0 || rate < 0) {
      ToastificationHelper.showWarning(
        context,
        'Select an item and enter valid quantity and rate.',
      );
      return null;
    }

    return LineItemFormData(
      itemId: _selectedItem!.id,
      itemName: name,
      imageUrl: _selectedItem!.imageUrl,
      description: _description.text.trim(),
      quantity: quantity,
      rate: rate,
      discount: double.tryParse(_discount.text) ?? 0,
      discountIsPercent: _discountIsPercent,
      taxRate: _taxRate,
    );
  }

  void _save() {
    final data = _validateAndBuild();
    if (data == null) return;
    markClean();
    Navigator.pop(context, widget.buildItem(data, widget.existingId));
  }

  void _saveAndNew() {
    final data = _validateAndBuild();
    if (data == null) return;
    markClean();
    // Pop with a single-element list — callers detect List<T> and re-open.
    Navigator.pop(context, <T>[widget.buildItem(data, widget.existingId)]);
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialData != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: CustomBackAppBar(
          title: isEditing ? 'Edit Line Item' : 'Add Line Item',
          onLeadingPressed: () => onPopInvokedWithResult(false, null),
        ),
        body: SafeArea(
          child: _isLoading
              ? const FormPageSkeleton(sectionFieldCounts: [3])
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    Dimensions.height15,
                    Dimensions.width20,
                    Dimensions.height30,
                  ),
                  child: FormCard(
                    children: [
                      const RequiredLabel(text: 'Item'),
                      SizedBox(height: Dimensions.height10 / 2),
                      ItemSearchField<ItemLookupResult>(
                        controller: _item,
                        isItemSelected: _selectedItem != null,
                        suggestions: _suggestions,
                        selectedItemImageUrl: _selectedItem?.imageUrl,
                        onChanged: _onSearchChanged,
                        onClear: _clearItem,
                        onBarcodeScan: () => ToastificationHelper.showInfo(
                          context,
                          'Barcode scan coming soon',
                        ),
                        suggestionBuilder: (apiItem) => InkWell(
                          onTap: () => _selectItem(apiItem),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height10,
                            ),
                            child: Row(
                              children: [
                                ItemThumbnail(imageUrl: apiItem.imageUrl),
                                SizedBox(width: Dimensions.width10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        apiItem.name,
                                        style: TextStyle(
                                          fontSize: Dimensions.font16 * 0.85,
                                          fontWeight: FontWeight.w700,
                                          color: context.colors.textPrimary,
                                        ),
                                      ),
                                      if (apiItem.costPrice > 0)
                                        Text(
                                          '₹${apiItem.costPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: Dimensions.font16 * 0.72,
                                            color: context.colors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_lookupController.isLoading) ...[
                        SizedBox(height: Dimensions.height10),
                        LinearProgressIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          minHeight: 2,
                        ),
                      ],
                      if (_selectedItem != null) ...[
                        const FormDivider(),
                        SizedBox(height: Dimensions.height10),
                        Text('Description', style: FormTextStyles.label()),
                        TextField(
                          controller: _description,
                          style: FormTextStyles.value(context),
                          decoration: InputDecoration(
                            hintText: 'Add a description for your item',
                            hintStyle: TextStyle(
                              color: context.colors.textTertiary,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                        const FormDivider(),
                        SizedBox(height: Dimensions.height15),
                        _numberRow('Quantity', _quantity, required: true),
                        SizedBox(height: Dimensions.height15),
                        _numberRow('Rate', _rate, required: true, prefix: '₹'),
                        SizedBox(height: Dimensions.height15),
                        _discountRow(),
                        SizedBox(height: Dimensions.height15),
                        _taxRow(),
                        SizedBox(height: Dimensions.height20),
                        _amountSummary(),
                      ],
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: _bottomActions(),
      ),
    );
  }

  // ── sub-widgets ────────────────────────────────────────────────────────────
  Widget _numberRow(
    String label,
    TextEditingController controller, {
    bool required = false,
    String? prefix,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        required
            ? RequiredLabel(text: label)
            : Text(label, style: FormTextStyles.label()),
        FormNumberField(
          controller: controller,
          hint: '0.00',
          prefix: prefix,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _discountRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Discount', style: FormTextStyles.label()),
        const Spacer(),
        FormNumberField(
          controller: _discount,
          hint: '0.00',
          width: Dimensions.height45 * 1.7,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(width: Dimensions.width10),
        Container(
          padding: EdgeInsets.all(Dimensions.height10 * 0.3),
          decoration: BoxDecoration(
            color: context.colors.surfaceLight,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _discountOption('%', true),
              _discountOption('₹', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _discountOption(String label, bool value) {
    final selected = _discountIsPercent == value;
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radius15 - 3),
      onTap: () => setState(() => _discountIsPercent = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width10,
          vertical: Dimensions.height10 / 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radius15 - 3),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.7,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _taxRow() {
    return Row(
      children: [
        Text('Tax', style: FormTextStyles.label()),
        const Spacer(),
        SizedBox(
          width: Dimensions.height45 * 2.5,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<double>(
              value: _taxRate,
              isExpanded: true,
              style: FormTextStyles.value(context),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.colors.textSecondary,
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('No Tax')),
                DropdownMenuItem(value: 5, child: Text('VAT 5%')),
                DropdownMenuItem(value: 10, child: Text('Tax 10%')),
              ],
              onChanged: (value) => setState(() => _taxRate = value ?? 0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _amountSummary() {
    return Container(
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _summaryRow('Amount', _net),
          SizedBox(height: Dimensions.height10 / 2),
          _summaryRow('Tax Amount', _taxAmount),
          const FormDivider(),
          _summaryRow('Total', _net + _taxAmount, bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.8,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: context.colors.textSecondary,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.85,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _bottomActions() {
    return SafeArea(
      child: Container(
        color: context.colors.card,
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          Dimensions.height10,
          Dimensions.width20,
          Dimensions.height10,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saveAndNew,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, Dimensions.height45 * 1.15),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                ),
                child: const Text('Save and New'),
              ),
            ),
            SizedBox(width: Dimensions.width15),
            Expanded(
              child: OutlinedButton(
                onPressed: _save,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  backgroundColor: Colors.transparent,
                  minimumSize: Size(0, Dimensions.height45 * 1.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
