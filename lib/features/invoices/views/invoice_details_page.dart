import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/invoices/controllers/invoice_detail_controller.dart';
import 'package:custom_books/features/invoices/models/invoice_model.dart';
import 'package:custom_books/features/invoices/views/new_invoice_page.dart';
import 'package:custom_books/features/invoices/widgets/invoice_details_tab_view.dart';
import 'package:custom_books/features/invoices/widgets/invoice_header_card.dart';
import 'package:flutter/material.dart';

class InvoiceDetailsPage extends StatefulWidget {
  /// The UUID of the invoice to load from the API.
  final String invoiceId;

  const InvoiceDetailsPage({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailsPage> createState() => _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState extends State<InvoiceDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InvoiceDetailController _controller = InvoiceDetailController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller.addListener(_onControllerChanged);
    _loadInvoice();
    appLog(
      '📄 InvoiceDetailsPage init: ${widget.invoiceId}',
      name: 'InvoiceDetailsPage',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadInvoice() async {
    await _controller.load(widget.invoiceId);
    if (!mounted) return;
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  Future<void> _sendInvoice() async {
    appLog('📤 Send invoice tapped', name: 'InvoiceDetailsPage');
    final error = await _controller.send(widget.invoiceId);
    if (!mounted) return;
    if (error == null) {
      ToastificationHelper.showSuccess(context, 'Invoice sent successfully.');
      // Reload the detail so the Send button disappears and status updates,
      // then signal the list to refresh when the user navigates back.
      await _loadInvoice();
      if (mounted) Navigator.pop(context, true);
    } else {
      ToastificationHelper.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = _controller.invoice;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomBackAppBar(
        title: 'Invoice Details',
        backgroundColor: context.colors.card,
        actions: [
          if (invoice != null && invoice.status == InvoiceStatus.draft)
            _controller.isSending
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10,
                      vertical: Dimensions.height10,
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : TextButton.icon(
                    onPressed: _sendInvoice,
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Send'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: TextStyle(
                        fontSize: Dimensions.font16 * 0.82,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          if (invoice != null)
            IconButton(
              icon: Icon(
                Icons.edit_rounded,
                color: context.colors.textSecondary,
                size: Dimensions.iconSize24 - 2,
              ),
              onPressed: () async {
                appLog('✏️ Edit invoice tapped', name: 'InvoiceDetailsPage');
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewInvoicePage(existingInvoice: invoice),
                  ),
                );
                // Refresh after editing
                if (mounted) _loadInvoice();
              },
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
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await showConfirmationDialog(
                  context,
                  title: 'Delete Invoice',
                  message:
                      'Are you sure you want to delete this invoice? This action cannot be undone.',
                );
                if (!confirmed || !context.mounted) return;

                final error = await _controller.delete(widget.invoiceId);
                if (!context.mounted) return;

                if (error == null) {
                  ToastificationHelper.showSuccess(
                    context,
                    'Invoice deleted successfully.',
                  );
                  Navigator.pop(context, true); // signal list to refresh
                } else {
                  ToastificationHelper.showError(context, error);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(
                      Icons.print_rounded,
                      size: Dimensions.iconSize16 + 4,
                      color: context.colors.textSecondary,
                    ),
                    SizedBox(width: Dimensions.width10),
                    Text(
                      'Print',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.85,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: Dimensions.iconSize16 + 4,
                      color: AppColors.warn,
                    ),
                    SizedBox(width: Dimensions.width10),
                    Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.85,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warn,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(width: Dimensions.width10),
        ],
      ),
      body: SafeArea(
        child: _controller.isLoading
            ? const DetailsPageSkeleton()
            : invoice == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: context.colors.textTertiary,
                    ),
                    SizedBox(height: Dimensions.height15),
                    Text(
                      _controller.errorMessage ??
                          'Invoice could not be loaded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.9,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),
                    TextButton.icon(
                      onPressed: _loadInvoice,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Header section
                  InvoiceHeaderCard(invoice: invoice),
                  SizedBox(height: Dimensions.height15),

                  // Tabs
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceLight,
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: context.colors.card,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius30,
                        ),
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
                        Tab(text: 'COMMENTS & HISTORY'),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height15),

                  // Tab content
                  Expanded(
                    child: InvoiceDetailsTabView(
                      invoice: invoice,
                      tabController: _tabController,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
