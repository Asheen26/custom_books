import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/customers/widgets/customer_details_page_widgets/comments_tab.dart';
import 'package:custom_books/features/purchase_orders/models/purchase_order_model.dart';
import 'package:custom_books/features/purchase_orders/views/add_purchase_order_page.dart';
import 'package:custom_books/features/purchase_orders/widgets/po_attachments_dialog.dart';
import 'package:custom_books/features/purchase_orders/widgets/po_bills_tab.dart';
import 'package:custom_books/features/purchase_orders/widgets/po_details_header.dart';
import 'package:custom_books/features/purchase_orders/widgets/po_details_tab.dart';
import 'package:custom_books/features/purchase_orders/widgets/po_email_page.dart';
import 'package:custom_books/features/purchase_orders/widgets/po_new_receive_page.dart';
import 'package:custom_books/features/purchase_orders/widgets/po_receives_tab.dart';
import 'package:flutter/material.dart';

class PurchaseOrderDetailsPage extends StatefulWidget {
  final PurchaseOrderModel order;

  const PurchaseOrderDetailsPage({super.key, required this.order});

  @override
  State<PurchaseOrderDetailsPage> createState() =>
      _PurchaseOrderDetailsPageState();
}

class _PurchaseOrderDetailsPageState extends State<PurchaseOrderDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

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

  void _openNewReceive() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PoNewReceivePage(order: widget.order)),
  );

  Future<void> _onMoreSelected(String value) async {
    switch (value) {
      case 'mark_issued':
        ToastificationHelper.showSuccess(context, 'Marked as Issued.');
      case 'convert_bill':
        ToastificationHelper.showInfo(context, 'Convert to Bill coming soon.');
      case 'receive_items':
        _openNewReceive();
      case 'create_receive':
        _openNewReceive();
      case 'change_template':
        ToastificationHelper.showInfo(context, 'Change Template coming soon.');
      case 'preview':
        ToastificationHelper.showInfo(context, 'Preview coming soon.');
      case 'download_pdf':
        ToastificationHelper.showInfo(context, 'Download PDF coming soon.');
      case 'print':
        ToastificationHelper.showInfo(context, 'Print coming soon.');
      case 'clone':
        ToastificationHelper.showInfo(context, 'Clone coming soon.');
      case 'delete':
        final confirmed = await showConfirmationDialog(
          context,
          title: 'Delete Purchase Order',
          message:
              'Are you sure you want to delete this purchase order? '
              'This action cannot be undone.',
        );
        if (confirmed && mounted) Navigator.pop(context);
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomBackAppBar(
        title: 'Purchase Order',
        backgroundColor: context.colors.card,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddPurchaseOrderPage(existing: widget.order),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.email_outlined,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PoEmailPage(order: widget.order),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
            ),
            surfaceTintColor: context.colors.card,
            color: context.colors.card,
            elevation: 8,
            onSelected: _onMoreSelected,
            itemBuilder: (ctx) => [
              _menuItem(
                ctx,
                'mark_issued',
                'Mark as Issued',
                Icons.check_circle_outline_rounded,
                AppColors.primary,
              ),
              _menuItem(
                ctx,
                'convert_bill',
                'Convert to Bill',
                Icons.receipt_long_outlined,
                AppColors.primary,
              ),
              PopupMenuItem<String>(
                enabled: false,
                height: Dimensions.height10 * 3,
                child: Text(
                  'Receive',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.82,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
              _menuItem(
                ctx,
                'receive_items',
                '   Receive Items',
                Icons.inventory_2_outlined,
                AppColors.primary,
              ),
              _menuItem(
                ctx,
                'create_receive',
                '   Create Receive',
                Icons.add_box_outlined,
                AppColors.primary,
              ),
              _menuItem(
                ctx,
                'change_template',
                'Change Template',
                Icons.dashboard_customize_outlined,
                context.colors.textSecondary,
              ),
              _menuItem(
                ctx,
                'preview',
                'Preview',
                Icons.visibility_outlined,
                context.colors.textSecondary,
              ),
              _menuItem(
                ctx,
                'download_pdf',
                'Download PDF',
                Icons.picture_as_pdf_outlined,
                context.colors.textSecondary,
              ),
              _menuItem(
                ctx,
                'print',
                'Print',
                Icons.print_outlined,
                context.colors.textSecondary,
              ),
              _menuItem(
                ctx,
                'clone',
                'Clone',
                Icons.copy_outlined,
                context.colors.textSecondary,
              ),
              _menuItem(
                ctx,
                'delete',
                'Delete',
                Icons.delete_outline_rounded,
                AppColors.warn,
              ),
            ],
          ),
          SizedBox(width: Dimensions.width10 / 2),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const DetailsPageSkeleton()
            : Column(
                children: [
                  PoDetailsHeader(
                    order: widget.order,
                    onAttachmentTap: () => showDialog(
                      context: context,
                      builder: (_) => PoAttachmentsDialog(order: widget.order),
                    ),
                  ),
                  Container(
                    color: context.colors.card,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: context.colors.textSecondary,
                      labelStyle: TextStyle(
                        fontSize: Dimensions.font16 * 0.75,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: Dimensions.font16 * 0.75,
                        fontWeight: FontWeight.w600,
                      ),
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2.5,
                        ),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: context.colors.border,
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width10 / 2,
                      ),
                      tabs: const [
                        Tab(text: 'DETAILS'),
                        Tab(text: 'BILLS'),
                        Tab(text: 'RECEIVES'),
                        Tab(text: 'COMMENTS & HISTORY'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        PoDetailsTab(order: widget.order),
                        const PoBillsTab(),
                        PoReceivesTab(order: widget.order),
                        const CommentsTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── popup menu item factory ────────────────────────────────────────────────

  PopupMenuItem<String> _menuItem(
    BuildContext ctx,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: Dimensions.iconSize16 + 4, color: color),
          SizedBox(width: Dimensions.width10),
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              fontWeight: FontWeight.w600,
              color: value == 'delete'
                  ? AppColors.warn
                  : ctx.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
