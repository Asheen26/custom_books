import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/sales_orders/models/sales_order_model.dart';
import 'package:custom_books/features/sales_orders/controllers/sales_order_detail_controller.dart';
import 'package:custom_books/features/sales_orders/controllers/sales_order_form_controller.dart';
import 'package:custom_books/features/sales_orders/views/add_sales_order_page.dart';
import 'package:custom_books/features/sales_orders/widgets/so_details_header.dart';
import 'package:custom_books/features/sales_orders/widgets/so_details_tab.dart';
import 'package:flutter/material.dart';

class SalesOrderDetailsPage extends StatefulWidget {
  final SalesOrderModel order;
  final ValueChanged<SalesOrderStatus>? onStatusChanged;
  final VoidCallback? onDelete;

  const SalesOrderDetailsPage({
    super.key,
    required this.order,
    this.onStatusChanged,
    this.onDelete,
  });

  @override
  State<SalesOrderDetailsPage> createState() => _SalesOrderDetailsPageState();
}

class _SalesOrderDetailsPageState extends State<SalesOrderDetailsPage> {
  final _detailCtrl = SalesOrderDetailController();
  final _formCtrl = SalesOrderFormController();
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  late SalesOrderModel _order;

  SalesOrderModel get order => _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _detailCtrl.seed(widget.order);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _detailCtrl.load(widget.order.id);
    if (!mounted) return;
    if (_detailCtrl.order != null) setState(() => _order = _detailCtrl.order!);
    if (_detailCtrl.errorMessage != null) {
      setState(() => _errorMessage = _detailCtrl.errorMessage);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _performAction(String action) async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);
    final updated = await _formCtrl.performAction(action, _order.id);
    if (!mounted) return;
    setState(() => _isActionLoading = false);
    if (updated != null) {
      setState(() => _order = updated);
      widget.onStatusChanged?.call(updated.status);
      ToastificationHelper.showSuccess(context, 'Status updated.');
      appLog(
        'SO $action success: ${updated.salesOrderNumber}',
        name: 'SalesOrderDetailsPage',
      );
    } else {
      ToastificationHelper.showError(
        context,
        _formCtrl.errorMessage ?? 'Action failed.',
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Sales Order',
      message:
          'Are you sure you want to delete this sales order? This action cannot be undone.',
    );
    if (!confirmed || !mounted) return;
    setState(() => _isActionLoading = true);
    final error = await _formCtrl.delete(_order.id);
    if (!mounted) return;
    setState(() => _isActionLoading = false);
    if (error == null) {
      widget.onDelete?.call();
      Navigator.pop(context);
      ToastificationHelper.showSuccess(context, 'Sales order deleted.');
    } else {
      ToastificationHelper.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomBackAppBar(
        title: 'Sales Order Details',
        backgroundColor: context.colors.card,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            onPressed: () async {
              final updated = await Navigator.push<SalesOrderModel>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddSalesOrderPage(existing: order),
                ),
              );
              if (updated != null && mounted) {
                setState(() => _order = updated);
                widget.onStatusChanged?.call(updated.status);
              }
            },
          ),
          _actionsMenu(),
          SizedBox(width: Dimensions.width10),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const DetailsPageSkeleton(showTabs: false, showLineItems: true)
            : Column(
                children: [
                  SoDetailsHeader(order: order),
                  Expanded(
                    child: SoDetailsTab(
                      order: order,
                      errorMessage: _errorMessage,
                      onRetry: _load,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _actionsMenu() {
    return PopupMenuButton<String>(
      icon: _isActionLoading
          ? SizedBox(
              width: Dimensions.iconSize24 - 2,
              height: Dimensions.iconSize24 - 2,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.colors.textSecondary,
                ),
              ),
            )
          : Icon(
              Icons.more_vert_rounded,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
      enabled: !_isActionLoading,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      surfaceTintColor: context.colors.card,
      color: context.colors.card,
      elevation: 8,
      onSelected: (value) async {
        switch (value) {
          case 'confirm':
            await _performAction('confirm');
          case 'cancel':
            await _performAction('cancel');
          case 'invoice':
            await _performAction('mark_invoiced');
          case 'print':
            ToastificationHelper.showInfo(
              context,
              'Printing sales orders is coming soon.',
            );
          case 'delete':
            _confirmDelete();
        }
      },
      itemBuilder: (context) => [
        if (order.status == SalesOrderStatus.draft)
          _mi(
            context,
            'confirm',
            Icons.check_circle_outline_rounded,
            'Mark as Confirmed',
            AppColors.success,
          ),
        if (order.status == SalesOrderStatus.draft ||
            order.status == SalesOrderStatus.confirmed)
          _mi(
            context,
            'cancel',
            Icons.cancel_outlined,
            'Cancel Order',
            AppColors.warn,
          ),
        if (order.status == SalesOrderStatus.confirmed)
          _mi(
            context,
            'invoice',
            Icons.receipt_long_rounded,
            'Mark as Invoiced',
            AppColors.primary,
          ),
        _mi(
          context,
          'print',
          Icons.print_rounded,
          'Print',
          context.colors.textSecondary,
        ),
        _mi(
          context,
          'delete',
          Icons.delete_outline_rounded,
          'Delete',
          AppColors.warn,
        ),
      ],
    );
  }

  PopupMenuItem<String> _mi(
    BuildContext ctx,
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem(
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
