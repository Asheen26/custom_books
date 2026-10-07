import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/line_item_form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/core/line_item/item_lookup_controller.dart';
import 'package:custom_books/features/inventory_adjustments/models/line_item_model.dart';
import 'package:custom_books/features/inventory_adjustments/widgets/cost_price_editor.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AddLineItemPage extends StatefulWidget {
  final LineItem? initial;

  const AddLineItemPage({super.key, this.initial});

  @override
  State<AddLineItemPage> createState() => _AddLineItemPageState();
}

class _AddLineItemPageState extends State<AddLineItemPage>
    with UnsavedChangesMixin {
  final _itemSearchController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _newQtyController = TextEditingController();
  final _adjustedController = TextEditingController();

  // Dedicated focus nodes for the qty fields so taps anywhere inside the
  // bordered box (not just directly on the digits) reliably open the
  // keyboard and place the cursor.
  final _newQtyFocusNode = FocusNode();
  final _adjustedFocusNode = FocusNode();

  InventoryItemLookup? _selectedItem;
  double _costPrice = 0;
  bool _syncing = false;
  bool _isLoading = true;

  final ItemLookupController _lookupController = ItemLookupController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
    _lookupController.addListener(_onLookupChanged);
    final initial = widget.initial;
    if (initial != null) {
      _selectedItem = InventoryItemLookup(
        id: initial.itemId,
        name: initial.itemName,
        stockOnHand: initial.stockOnHand,
        imageUrl: initial.imageUrl,
        costPrice: initial.costPrice,
      );
      _itemSearchController.text = initial.itemName;
      _descriptionController.text = initial.description ?? '';
      _newQtyController.text = initial.newQuantityOnHand.toStringAsFixed(2);
      _adjustedController.text = initial.quantityAdjusted.toStringAsFixed(2);
      _costPrice = initial.costPrice;
    }
    _descriptionController.addListener(markDirty);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _lookupController.removeListener(_onLookupChanged);
    _lookupController.dispose();
    _descriptionController.removeListener(markDirty);
    _itemSearchController.dispose();
    _descriptionController.dispose();
    _newQtyController.dispose();
    _adjustedController.dispose();
    _newQtyFocusNode.dispose();
    _adjustedFocusNode.dispose();
    super.dispose();
  }

  void _onLookupChanged() {
    if (mounted) setState(() {});
  }

  /// Debounced item search against the API.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    // Typing after a selection means the user wants to search again.
    if (_selectedItem != null) {
      setState(() => _selectedItem = null);
    }
    final q = value.trim();
    if (q.isEmpty) {
      _lookupController.clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _lookupController.search(q);
    });
  }

  /// Simulates preparing the form so the shimmer skeleton is shown briefly.
  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  List<InventoryItemLookup> get _suggestions {
    if (_itemSearchController.text.trim().isEmpty || _selectedItem != null) {
      return [];
    }
    return _lookupController.results;
  }

  void _selectItem(InventoryItemLookup item) {
    appLog(
      '📦 Item selected: ${item.name}, stockOnHand: ${item.stockOnHand}',
      name: 'AddLineItem',
    );
    setState(() {
      _selectedItem = item;
      _itemSearchController.text = item.name;
      _costPrice = item.costPrice;
      _newQtyController.clear();
      _adjustedController.clear();
    });
    markDirty();
    appLog(
      '✅ Item selection complete. _selectedItem is now: ${_selectedItem?.name}',
      name: 'AddLineItem',
    );
    FocusScope.of(context).unfocus();
  }

  void _clearItem() {
    appLog('🗑️ Clearing selected item', name: 'AddLineItem');
    _debounce?.cancel();
    setState(() {
      _selectedItem = null;
      _itemSearchController.clear();
      _newQtyController.clear();
      _adjustedController.clear();
    });
    _lookupController.clear();
    appLog('✅ Item cleared. _selectedItem is now: null', name: 'AddLineItem');
  }

  void _onNewQtyChanged(String value) {
    if (_syncing || _selectedItem == null) return;
    markDirty();
    final newQty = double.tryParse(value);
    if (newQty == null) return;
    _syncing = true;
    final adjusted = newQty - _selectedItem!.stockOnHand;
    _adjustedController.text = adjusted.toStringAsFixed(2);
    _syncing = false;
  }

  void _onAdjustedChanged(String value) {
    if (_syncing || _selectedItem == null) return;
    markDirty();
    final adjusted = double.tryParse(value);
    if (adjusted == null) return;
    _syncing = true;
    final newQty = _selectedItem!.stockOnHand + adjusted;
    _newQtyController.text = newQty.toStringAsFixed(2);
    _syncing = false;
  }

  void _done() {
    if (_selectedItem == null) {
      ToastificationHelper.showWarning(context, 'Please select an item.');
      return;
    }

    final newQty = double.tryParse(_newQtyController.text.trim());
    final adjusted = double.tryParse(_adjustedController.text.trim());

    if (newQty == null || adjusted == null) {
      ToastificationHelper.showWarning(
        context,
        'Please enter New quantity on hand and Quantity Adjusted.',
      );
      return;
    }

    final lineItem = LineItem(
      id:
          widget.initial?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: _selectedItem!.id,
      itemName: _selectedItem!.name,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      imageUrl: _selectedItem!.imageUrl,
      stockOnHand: _selectedItem!.stockOnHand,
      newQuantityOnHand: newQty,
      quantityAdjusted: adjusted,
      costPrice: _costPrice,
    );
    markClean();
    Navigator.pop(context, lineItem);
  }

  @override
  Widget build(BuildContext context) {
    appLog(
      '🏗️ Building AddLineItemPage - _selectedItem: ${_selectedItem?.name ?? "null"}',
      name: 'AddLineItem',
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: CustomBackAppBar(
          title: 'Add Line Item',
          onLeadingPressed: () => onPopInvokedWithResult(false, null),
          actions: [
            TextButton(
              onPressed: _done,
              child: Text(
                'DONE',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: Dimensions.width10),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? const FormPageSkeleton(sectionFieldCounts: [3])
              : SingleChildScrollView(
                  padding: EdgeInsets.all(Dimensions.width20),
                  physics: const BouncingScrollPhysics(),
                  child: FormCard(
                    children: [
                      const RequiredLabel(text: 'Item'),
                      SizedBox(height: Dimensions.height10 / 2),
                      ItemSearchField<InventoryItemLookup>(
                        controller: _itemSearchController,
                        isItemSelected: _selectedItem != null,
                        suggestions: _suggestions,
                        selectedItemImageUrl: _selectedItem?.imageUrl,
                        onChanged: _onSearchChanged,
                        onClear: _clearItem,
                        onBarcodeScan: () => ToastificationHelper.showInfo(
                          context,
                          'Barcode scan coming soon',
                        ),
                        suggestionBuilder: (item) => InkWell(
                          onTap: () => _selectItem(item),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height10,
                            ),
                            child: Row(
                              children: [
                                ItemThumbnail(imageUrl: item.imageUrl),
                                SizedBox(width: Dimensions.width10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: Dimensions.font16 * 0.85,
                                          color: context.colors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: Dimensions.height10 / 4),
                                      Text.rich(
                                        TextSpan(
                                          text: 'Stock on Hand: ',
                                          style: TextStyle(
                                            color: context.colors.textSecondary,
                                            fontSize: Dimensions.font16 * 0.75,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: item.stockOnHand
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                color: item.stockOnHand < 0
                                                    ? Colors.red.shade600
                                                    : Colors.green.shade600,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
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
                      if (_selectedItem != null) ...[
                        const FormDivider(),
                        SizedBox(height: Dimensions.height10),
                        Text('Description', style: FormTextStyles.label()),
                        TextField(
                          controller: _descriptionController,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stock on Hand',
                              style: FormTextStyles.label(),
                            ),
                            Text(
                              _selectedItem!.stockOnHand.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.9,
                                fontWeight: FontWeight.w700,
                                color: _selectedItem!.stockOnHand < 0
                                    ? Colors.red.shade600
                                    : context.colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.height15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'New quantity on hand',
                              style: FormTextStyles.label(),
                            ),
                            FormNumberField(
                              controller: _newQtyController,
                              focusNode: _newQtyFocusNode,
                              signed: true,
                              hint: '0.00',
                              onChanged: _onNewQtyChanged,
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.height15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quantity Adjusted',
                              style: FormTextStyles.label(),
                            ),
                            FormNumberField(
                              controller: _adjustedController,
                              focusNode: _adjustedFocusNode,
                              signed: true,
                              hint: 'Eg. +10, -10',
                              onChanged: _onAdjustedChanged,
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.height15),
                        Row(
                          children: [
                            Text(
                              'Cost Price: ',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.85,
                                color: context.colors.textSecondary,
                              ),
                            ),
                            Text(
                              '₹${_costPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.85,
                                fontWeight: FontWeight.w700,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            SizedBox(width: Dimensions.width10 / 2),
                            InkWell(
                              onTap: () async {
                                final result = await CostPriceEditor.show(
                                  context,
                                  initialValue: _costPrice,
                                );
                                if (result != null) {
                                  setState(() => _costPrice = result);
                                  markDirty();
                                }
                              },
                              child: Icon(
                                Icons.edit_rounded,
                                size: Dimensions.iconSize24 - 8,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
