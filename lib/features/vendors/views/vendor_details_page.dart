import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/customers/widgets/customer_details_page_widgets/comments_tab.dart';
import 'package:custom_books/features/vendors/models/vendor_model.dart';
import 'package:custom_books/features/vendors/views/add_vendor_page.dart';
import 'package:custom_books/features/vendors/widgets/vendor_contact_info_section.dart';
import 'package:custom_books/features/vendors/widgets/vendor_contact_persons_section.dart';
import 'package:custom_books/features/vendors/widgets/vendor_more_info_section.dart';
import 'package:custom_books/features/vendors/widgets/vendor_payables_section.dart';
import 'package:custom_books/features/vendors/widgets/vendor_purchases_tab.dart';
import 'package:custom_books/features/vendors/widgets/vendor_sales_tab.dart';
import 'package:flutter/material.dart';

class VendorDetailsPage extends StatefulWidget {
  final VendorModel vendor;

  const VendorDetailsPage({super.key, required this.vendor});

  @override
  State<VendorDetailsPage> createState() => _VendorDetailsPageState();
}

class _VendorDetailsPageState extends State<VendorDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // ── tab indices ──────────────────────────────────────────────────────────
  static const int _kSales = 1;
  static const int _kPurchases = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  // ── navigation helpers ───────────────────────────────────────────────────

  void _openEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddVendorPage(existing: widget.vendor)),
    );
  }

  /// Dispatches a menu action selected from the three-dot popup.
  /// Must be called synchronously (not inside a Future callback that crosses
  /// an async gap) so BuildContext use is safe.
  void _handleMenuAction(String action) {
    appLog('⚙️ More option: $action', name: 'VendorDetailsPage');
    switch (action) {
      case 'new_transaction':
        _showNewTransactionSheet();
      case 'email':
        ToastificationHelper.showInfo(context, 'Email coming soon.');
      case 'statement':
        ToastificationHelper.showInfo(context, 'Statement coming soon.');
      case 'history':
        ToastificationHelper.showInfo(context, 'History coming soon.');
      case 'mark_inactive':
        ToastificationHelper.showInfo(context, 'Mark as inactive coming soon.');
      case 'delete':
        _confirmDelete();
    }
  }

  PopupMenuItem<String> _menuItem(
    BuildContext context,
    String value,
    String label, {
    Color? color,
    Widget? trailing,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.9,
                color: color ?? context.colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  void _showNewTransactionSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewTransactionSheet(vendor: widget.vendor),
    );
  }

  void _confirmDelete() {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
        ),
        title: Text(
          'Delete Vendor',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.vendor.displayName}"? This action cannot be undone.',
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.warn,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: const DetailsPageSkeleton(
            headerStyle: DetailsHeaderStyle.twoMetric,
            tabStyle: DetailsTabStyle.pill,
            tabCount: 4,
            showTotalsCard: false,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, _) => [
            // ── App bar ────────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: context.colors.background,
              surfaceTintColor: context.colors.background,
              elevation: 0,
              toolbarHeight: Dimensions.height45 * 1.6,
              titleSpacing: 0,
              leading: IconButton(
                icon: Container(
                  width: Dimensions.height45 * 0.9,
                  height: Dimensions.height45 * 0.9,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: Dimensions.iconSize24 - 4,
                    color: AppColors.primary,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.vendor.displayName,
                style: TextStyle(
                  fontSize: Dimensions.font26 * 0.85,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              actions: [
                // Edit
                AppBarIconButton(
                  icon: Icons.edit_outlined,
                  onPressed: _openEdit,
                ),
                SizedBox(width: Dimensions.width10 / 2),
                // Attach
                AppBarIconButton(
                  icon: Icons.attach_file_rounded,
                  color: AppColors.accent,
                  onPressed: () {
                    appLog('📎 Attach tapped', name: 'VendorDetailsPage');
                    ToastificationHelper.showInfo(
                      context,
                      'Attach file coming soon.',
                    );
                  },
                ),
                SizedBox(width: Dimensions.width10 / 2),
                // More options (three-dot)
                Builder(
                  builder: (ctx) => AppBarIconButton(
                    icon: Icons.more_vert_rounded,
                    color: AppColors.accent,
                    onPressed: () {
                      // Use the Builder context so findRenderObject resolves
                      // to the icon button itself for correct menu positioning.
                      final RenderBox btn = ctx.findRenderObject() as RenderBox;
                      final RenderBox overlay =
                          Navigator.of(ctx).overlay!.context.findRenderObject()
                              as RenderBox;
                      final RelativeRect pos = RelativeRect.fromRect(
                        Rect.fromPoints(
                          btn.localToGlobal(Offset.zero, ancestor: overlay),
                          btn.localToGlobal(
                            btn.size.bottomRight(Offset.zero),
                            ancestor: overlay,
                          ),
                        ),
                        Offset.zero & overlay.size,
                      );
                      showMenu<String>(
                        context: ctx,
                        position: pos,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius15,
                          ),
                        ),
                        color: context.colors.card,
                        items: [
                          _menuItem(
                            ctx,
                            'new_transaction',
                            'New Transaction',
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              size: Dimensions.iconSize20,
                              color: context.colors.textSecondary,
                            ),
                          ),
                          _menuItem(ctx, 'email', 'Email'),
                          _menuItem(ctx, 'statement', 'Statement'),
                          _menuItem(ctx, 'history', 'History'),
                          _menuItem(ctx, 'mark_inactive', 'Mark as Inactive'),
                          _menuItem(
                            ctx,
                            'delete',
                            'Delete',
                            color: AppColors.warn,
                          ),
                        ],
                      ).then((value) {
                        if (value == null || !mounted) return;
                        appLog(
                          '⚙️ More option: $value',
                          name: 'VendorDetailsPage',
                        );
                        _handleMenuAction(value);
                      });
                    },
                  ),
                ),
                SizedBox(width: Dimensions.width20),
              ],
            ),

            // ── Summary header (2×2 grid) ─────────────────────────────────
            SliverToBoxAdapter(child: _buildSummaryHeader()),

            // ── Tab bar (pill style) ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: context.colors.background,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height10,
                ),
                child: Container(
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
                    unselectedLabelStyle: TextStyle(
                      fontSize: Dimensions.font16 * 0.72,
                      fontWeight: FontWeight.w600,
                    ),
                    dividerColor: Colors.transparent,
                    padding: EdgeInsets.all(Dimensions.width10 / 2),
                    tabs: const [
                      Tab(text: 'DETAILS'),
                      Tab(text: 'SALES'),
                      Tab(text: 'PURCHASES'),
                      Tab(text: 'COMMENTS'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(),
              const VendorSalesTab(),
              VendorPurchasesTab(onAddTransaction: _showNewTransactionSheet),
              const CommentsTab(),
            ],
          ),
        ),
      ),

      // ── FAB (shown on Sales & Purchases tabs) ──────────────────────────
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (_, child) {
          final idx = _tabController.index;
          if (idx != _kSales && idx != _kPurchases) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            backgroundColor: context.colors.textPrimary,
            foregroundColor: context.colors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius20),
            ),
            onPressed: _showNewTransactionSheet,
            child: Icon(Icons.add, size: Dimensions.iconSize24),
          );
        },
      ),
    );
  }

  // ── Summary header ───────────────────────────────────────────────────────

  Widget _buildSummaryHeader() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border(
          bottom: BorderSide(color: context.colors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Row 1: Receivables | Unused Credits
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _summaryCell(
                    label: 'Receivables',
                    value: '₹${widget.vendor.payables.toStringAsFixed(2)}',
                  ),
                ),
                VerticalDivider(width: 1, color: context.colors.border),
                Expanded(
                  child: _summaryCell(
                    label: 'Unused Credits',
                    value: '₹${widget.vendor.unusedCredits.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.border),
          // Row 2: Payables | Unused Credits
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _summaryCell(
                    label: 'Payables',
                    value: '₹${widget.vendor.payables.toStringAsFixed(2)}',
                  ),
                ),
                VerticalDivider(width: 1, color: context.colors.border),
                Expanded(
                  child: _summaryCell(
                    label: 'Unused Credits',
                    value: '₹${widget.vendor.unusedCredits.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCell({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.75,
              color: context.colors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Dimensions.height10 / 2),
          Text(
            value,
            style: TextStyle(
              fontSize: Dimensions.font20 * 0.95,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Details tab ──────────────────────────────────────────────────────────

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: Dimensions.height20),

          // Contact info card (name + currency + action icons)
          VendorContactInfoSection(
            vendor: widget.vendor,
            onDial: () =>
                ToastificationHelper.showInfo(context, 'Dial coming soon.'),
            onEmail: () =>
                ToastificationHelper.showInfo(context, 'Email coming soon.'),
          ),

          // Receivables section
          VendorReceivablesSection(
            vendor: widget.vendor,
            onEnterOpeningBalance: _openEdit,
          ),

          // Payables section
          VendorPayablesSection(
            vendor: widget.vendor,
            onEnterOpeningBalance: _openEdit,
          ),

          // More Information section
          VendorMoreInfoSection(vendor: widget.vendor),

          // Contact Persons section
          VendorContactPersonsSection(
            onAddContactPerson: () => ToastificationHelper.showInfo(
              context,
              'Add Contact Person coming soon.',
            ),
          ),

          SizedBox(height: Dimensions.listBottomSpace),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// New Transaction bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _NewTransactionSheet extends StatelessWidget {
  final VendorModel vendor;

  const _NewTransactionSheet({required this.vendor});

  static const _salesItems = [
    'Invoice',
    'Customer Payment',
    'Quote',
    'Sales Order',
    'Package',
    'Shipment',
    'Delivery Challan',
    'Expenses',
    'Project',
    'Journal',
    'Bills',
    'Credit Note',
  ];

  static const _purchaseItems = [
    'Bills',
    'Bill Payment',
    'Expenses',
    'Purchase Order',
    'Vendor Credits',
    'Journal',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        Dimensions.width20,
        Dimensions.height20,
        Dimensions.width20,
        Dimensions.height20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: Dimensions.width30 * 1.5,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: Dimensions.height20),
          Text(
            'New Transaction',
            style: TextStyle(
              fontSize: Dimensions.font16 * 1.1,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: Dimensions.height15),
          Divider(color: context.colors.border),
          SizedBox(height: Dimensions.height10),
          Text(
            'SALES',
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.68,
              fontWeight: FontWeight.w700,
              color: context.colors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          ..._salesItems.map((item) => _sheetItem(context, item)),
          SizedBox(height: Dimensions.height15),
          Divider(color: context.colors.border),
          SizedBox(height: Dimensions.height10),
          Text(
            'PURCHASES',
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.68,
              fontWeight: FontWeight.w700,
              color: context.colors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          ..._purchaseItems.map((item) => _sheetItem(context, item)),
        ],
      ),
    );
  }

  Widget _sheetItem(BuildContext context, String label) {
    return InkWell(
      onTap: () {
        appLog('➕ New transaction: $label', name: 'VendorDetailsPage');
        Navigator.pop(context);
        ToastificationHelper.showInfo(context, '$label coming soon.');
      },
      borderRadius: BorderRadius.circular(Dimensions.radius15 / 1.5),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10 * 0.9),
        child: Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.9,
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
