import 'dart:async';

import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/line_item_form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/inventory_adjustments/controllers/item_lookup_controller.dart';
import 'package:custom_books/features/inventory_adjustments/models/line_item_model.dart';
import 'package:custom_books/features/recurring_invoices/models/recurring_invoice_model.dart';
import 'package:flutter/material.dart';

class AddRecurringInvoiceLineItemPage extends StatefulWidget {
  const AddRecurringInvoiceLineItemPage({super.key});

  @override
  State<AddRecurringInvoiceLineItemPage> createState() =>
      _AddRecurringInvoiceLineItemPageState();
}

class _AddRecurringInvoiceLineItemPageState
    extends State<AddRecurringInvoiceLineItemPage>
    with UnsavedChangesMixin {
  final _item = TextEditingController();
  final _description = TextEditingController();
  final _quantity = TextEditingController(text: '1.00');
  final _rate = TextEditingController(text: '0.00');
  final _discount = TextEditingController();
  InventoryItemLookup? _selectedItem;
  bool _discountIsPercent = true;
  double _taxRate = 0;
  bool _isLoading = true;

  final ItemLookupController _lookupController = ItemLookupController();
  Timer? _debounce;

  List<InventoryItemLookup> get _suggestions {
    if (_item.text.trim().isEmpty || _selectedItem != null) return [];
    return _lookupController.results;
  }

  double get _gross =>
      (double.tryParse(_quantity.text) ?? 0) *
      (double.tryParse(_rate.text) ?? 0);
  double get _discountAmount {
    final discount = double.tryParse(_discount.text) ?? 0;
    return _discountIsPercent ? _gross * discount / 100 : discount;
  }

  double get _net => (_gross - _discountAmount).clamp(0, double.infinity);
  double get _taxAmount => _net * _taxRate / 100;

  @override
  void initState() {
    super.initState();
    _load();
    _lookupController.addListener(_onLookupChanged);
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

  void _selectItem(InventoryItemLookup apiItem) {
    appLog(
      '📦 Recurring Invoice item selected: ${apiItem.name}',
      name: 'AddRecurringInvoiceLineItem',
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

  RecurringInvoiceLineItem? _buildItem() {
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
    return RecurringInvoiceLineItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      itemId: _selectedItem!.id,
      itemName: name,
      description: _description.text.trim(),
      quantity: quantity,
      rate: rate,
      discount: double.tryParse(_discount.text) ?? 0,
      discountIsPercent: _discountIsPercent,
      taxRate: _taxRate,
    );
  }

  void _save() {
    final item = _buildItem();
    if (item != null) {
      markClean();
      Navigator.pop(context, item);
    }
  }

  void _saveAndNew() {
    final item = _buildItem();
    if (item == null) return;
    markClean();
    Navigator.pop(context, <RecurringInvoiceLineItem>[
      item,
      const RecurringInvoiceLineItem(
        id: '',
        itemName: '',
        quantity: 0,
        rate: 0,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: CustomBackAppBar(
          title: 'Add Line Item',
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
                      ItemSearchField<InventoryItemLookup>(
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
            children: [_discountOption('%', true), _discountOption('₹', false)],
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

  Widget _summaryRow(String label, double amount, {bool bold = false}) => Row(
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
