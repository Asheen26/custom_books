import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/more_options_sheet.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/items/controllers/item_detail_controller.dart';
import 'package:custom_books/features/items/controllers/item_form_controller.dart';
import 'package:custom_books/features/items/models/item_model.dart';
import 'package:custom_books/features/items/views/add_edit_item_page.dart';
import 'package:custom_books/features/items/views/adjust_stock_page.dart';
import 'package:custom_books/features/items/widgets/item_details_header.dart';
import 'package:custom_books/features/items/widgets/item_details_tab.dart';
import 'package:custom_books/features/items/widgets/item_history_tab.dart';
import 'package:custom_books/features/items/widgets/item_transactions_tab.dart';
import 'package:flutter/material.dart';

class ItemDetailsPage extends StatefulWidget {
  final ItemModel item;
  const ItemDetailsPage({super.key, required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage>
    with SingleTickerProviderStateMixin {
  final ItemDetailController _controller = ItemDetailController();
  final ItemFormController _formController = ItemFormController();
  late final TabController _tabController;
  bool _isLoading = true;
  bool _didChange = false;
  late ItemModel item = widget.item;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    _formController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await _controller.load(widget.item.id);
    if (!mounted) return;
    setState(() {
      final fetched = _controller.item;
      if (fetched != null) item = fetched;
      _isLoading = false;
    });
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  Future<void> _editItem() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditItemPage(existing: item)),
    );
    if (updated == true && mounted) {
      _didChange = true;
      _load();
    }
  }

  Future<void> _cloneItem() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditItemPage(cloneFrom: item)),
    );
    if (created == true && mounted) {
      _didChange = true;
      ToastificationHelper.showSuccess(context, 'Item cloned successfully.');
    }
  }

  Future<void> _adjustStock() async {
    final adjusted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdjustStockPage(item: item)),
    );
    if (adjusted == true && mounted) {
      _didChange = true;
      _load();
    }
  }

  Future<void> _setActive(bool active) async {
    final ok = await _formController.update(item.id, {
      'status': active ? 'active' : 'inactive',
    });
    if (!mounted) return;
    if (ok) {
      _didChange = true;
      ToastificationHelper.showSuccess(
        context,
        active ? 'Item marked as active.' : 'Item marked as inactive.',
      );
      _load();
    } else {
      ToastificationHelper.showError(
        context,
        _formController.errorMessage ?? 'Could not update item status.',
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Item',
      message:
          'Are you sure you want to delete this item? This action cannot be undone.',
    );
    if (!mounted || !confirmed) return;
    final ok = await _formController.delete(item.id);
    if (!mounted) return;
    if (ok) {
      ToastificationHelper.showSuccess(context, 'Item deleted successfully.');
      Navigator.pop(context, true);
    } else {
      ToastificationHelper.showError(
        context,
        _formController.errorMessage ?? 'Could not delete the item.',
      );
    }
  }

  void _showMoreOptions() {
    MoreOptionsSheet.show(
      context,
      sectionLabel: 'ITEM ACTIONS',
      items: [
        MoreOptionsItem(
          icon: Icons.tune_rounded,
          title: 'Adjust Stock',
          subtitle: 'Update the quantity on hand',
          onTap: _adjustStock,
        ),
        MoreOptionsItem(
          icon: Icons.copy_rounded,
          title: 'Clone',
          subtitle: 'Create a copy of this item',
          onTap: _cloneItem,
        ),
        MoreOptionsItem(
          icon: item.isActive
              ? Icons.toggle_off_outlined
              : Icons.toggle_on_outlined,
          title: item.isActive ? 'Mark as Inactive' : 'Mark as Active',
          subtitle: item.isActive
              ? 'Hide this item from active lists'
              : 'Restore this item to active',
          onTap: () => _setActive(!item.isActive),
        ),
        MoreOptionsItem(
          icon: Icons.delete_outline_rounded,
          title: 'Delete',
          subtitle: 'Permanently remove this item',
          onTap: _confirmDelete,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _didChange);
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: CustomBackAppBar(
          title: 'Item',
          backgroundColor: context.colors.card,
          onLeadingPressed: () => Navigator.pop(context, _didChange),
          actions: [
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: context.colors.textSecondary,
                size: Dimensions.iconSize24 - 2,
              ),
              onPressed: _editItem,
            ),
            IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
                color: context.colors.textSecondary,
                size: Dimensions.iconSize24 - 2,
              ),
              onPressed: _showMoreOptions,
            ),
            SizedBox(width: Dimensions.width10 / 2),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? const DetailsPageSkeleton()
              : Column(
                  children: [
                    ItemDetailsHeader(item: item),
                    SizedBox(height: Dimensions.height15),
                    _pillTabBar(),
                    SizedBox(height: Dimensions.height15),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          ItemDetailsTab(item: item),
                          ItemTransactionsTab(item: item),
                          ItemHistoryTab(item: item),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _pillTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.surfaceLight,
        borderRadius: BorderRadius.circular(Dimensions.radius30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(Dimensions.radius30),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: Dimensions.radius15 * 0.53,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.primary,
        unselectedLabelColor: context.colors.textSecondary,
        labelStyle: TextStyle(
          fontSize: Dimensions.font16 * 0.72,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
        dividerColor: Colors.transparent,
        padding: EdgeInsets.all(Dimensions.width10 / 2),
        tabs: const [
          Tab(text: 'DETAILS'),
          Tab(text: 'TRANSACTIONS'),
          Tab(text: 'HISTORY'),
        ],
      ),
    );
  }
}
