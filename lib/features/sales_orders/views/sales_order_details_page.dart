import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/features/sales_orders/models/sales_order_model.dart';
import 'package:custom_books/features/sales_orders/viewmodels/sales_orders_list_viewmodel.dart';
import 'package:custom_books/features/sales_orders/views/add_sales_order_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';

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
  final _vm = SalesOrdersListViewModel();

  bool _isLoading = true;
  bool _isActionLoading = false;
  String? _errorMessage;

  late SalesOrderModel _order;

  SalesOrderModel get order => _order;
  ValueChanged<SalesOrderStatus>? get onStatusChanged => widget.onStatusChanged;
  VoidCallback? get onDelete => widget.onDelete;

  NumberFormat get _currency =>
      NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _order = widget.order; // show passed-in data instantly
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final resp = await _vm.fetchSalesOrderDetail(widget.order.id);
    if (!mounted) return;

    final int? statusCode = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        setState(() => _order = SalesOrderModel.fromJson(data));
        appLog(
          'Sales Order detail loaded: ${_order.salesOrderNumber}',
          name: 'SalesOrderDetailsPage',
        );
      }
    } else {
      final msg =
          (resp?['message'] ?? 'Failed to load sales order details.').toString();
      setState(() => _errorMessage = msg);
      appLog(
        'Sales Order detail fetch failed (status: $statusCode): $msg',
        name: 'SalesOrderDetailsPage',
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  /// Calls the appropriate status-action endpoint, updates local state from
  /// the server response, then notifies the parent list page.
  Future<void> _performAction(String action) async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);

    final Future<Map<String, dynamic>?> call;
    switch (action) {
      case 'confirm':
        call = _vm.confirmSalesOrder(_order.id);
      case 'cancel':
        call = _vm.cancelSalesOrder(_order.id);
      case 'mark_invoiced':
        call = _vm.markSalesOrderInvoiced(_order.id);
      default:
        setState(() => _isActionLoading = false);
        return;
    }

    final resp = await call;
    if (!mounted) return;

    final int? statusCode = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        final updated = SalesOrderModel.fromJson(data);
        setState(() => _order = updated);
        onStatusChanged?.call(updated.status);
        final msg = (resp['message'] ?? 'Status updated.').toString();
        ToastificationHelper.showSuccess(context, msg);
        appLog(
          'Sales Order $action success: ${updated.salesOrderNumber} -> ${updated.status}',
          name: 'SalesOrderDetailsPage',
        );
      }
    } else {
      final msg =
          (resp?['message'] ?? 'Action failed. Please try again.').toString();
      ToastificationHelper.showError(context, msg);
      appLog(
        'Sales Order $action failed (status: $statusCode): $msg',
        name: 'SalesOrderDetailsPage',
      );
    }

    if (mounted) setState(() => _isActionLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = order.status.color;

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddSalesOrderPage(existing: order),
                ),
              );
            },
          ),
          _buildActionsMenu(context),
          SizedBox(width: Dimensions.width10),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const DetailsPageSkeleton(showTabs: false, showLineItems: true)
            : _errorMessage != null
            ? _buildErrorState(context)
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(context, statusColor),
                  SizedBox(height: Dimensions.height15),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                    ),
                    child: Column(
                      children: [
                        _buildInfoCard(context),
                        SizedBox(height: Dimensions.height15),
                        _buildLineItemsCard(context),
                        SizedBox(height: Dimensions.height15),
                        _buildTotalsCard(context),
                        if (order.customerNotes.isNotEmpty) ...[
                          SizedBox(height: Dimensions.height15),
                          _buildNoteCard(
                            context,
                            'Customer Notes',
                            order.customerNotes,
                          ),
                        ],
                        if (order.termsAndConditions.isNotEmpty) ...[
                          SizedBox(height: Dimensions.height15),
                          _buildNoteCard(
                            context,
                            'Terms & Conditions',
                            order.termsAndConditions,
                          ),
                        ],
                        SizedBox(height: Dimensions.height30),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Dimensions.width20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: Dimensions.iconSize24 * 2,
              color: context.colors.textTertiary,
            ),
            SizedBox(height: Dimensions.height15),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.9,
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: _isActionLoading
          ? SizedBox(
              width: Dimensions.iconSize24 - 2,
              height: Dimensions.iconSize24 - 2,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(context.colors.textSecondary),
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
            _confirmDelete(context);
        }
      },
      itemBuilder: (context) => [
        if (order.status == SalesOrderStatus.draft)
          _menuItem(
            context,
            value: 'confirm',
            icon: Icons.check_circle_outline_rounded,
            label: 'Mark as Confirmed',
            color: AppColors.success,
          ),
        if (order.status == SalesOrderStatus.draft ||
            order.status == SalesOrderStatus.confirmed)
          _menuItem(
            context,
            value: 'cancel',
            icon: Icons.cancel_outlined,
            label: 'Cancel Order',
            color: AppColors.warn,
          ),
        if (order.status == SalesOrderStatus.confirmed)
          _menuItem(
            context,
            value: 'invoice',
            icon: Icons.receipt_long_rounded,
            label: 'Mark as Invoiced',
            color: AppColors.primary,
          ),
        _menuItem(
          context,
          value: 'print',
          icon: Icons.print_rounded,
          label: 'Print',
          color: context.colors.textSecondary,
        ),
        _menuItem(
          context,
          value: 'delete',
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          color: AppColors.warn,
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
    BuildContext context, {
    required String value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
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
                  : context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Sales Order',
      message:
          'Are you sure you want to delete this sales order? This action cannot be undone.',
    );
    if (!confirmed || !context.mounted) return;

    setState(() => _isActionLoading = true);

    final resp = await _vm.deleteSalesOrder(_order.id);
    if (!mounted) return;

    setState(() => _isActionLoading = false);

    final int? statusCode = resp?['_statusCode'] as int?;
    final bool ok = resp != null &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300;

    if (ok) {
      final msg =
          (resp['message'] ?? 'Sales order deleted.').toString();
      appLog(
        'Sales Order deleted: ${_order.salesOrderNumber}',
        name: 'SalesOrderDetailsPage',
      );
      onDelete?.call();
      Navigator.pop(context);
      // Toast shown after pop so it appears on the list page
      ToastificationHelper.showSuccess(context, msg);
    } else {
      final msg =
          (resp?['message'] ?? 'Could not delete. Please try again.').toString();
      ToastificationHelper.showError(context, msg);
      appLog(
        'Sales Order delete failed (status: $statusCode): $msg',
        name: 'SalesOrderDetailsPage',
      );
    }
  }

  Widget _buildHeader(BuildContext context, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: Dimensions.radius15 * 0.53,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Date',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.7,
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10 + 2,
                  vertical: Dimensions.height10 * 0.5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Dimensions.radius30),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.62,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height10 / 2.5),
          Text(
            formatDate(order.salesOrderDate),
            style: TextStyle(
              fontSize: Dimensions.font20 * 0.95,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: Dimensions.height20),
          Text(
            order.customerName,
            style: TextStyle(
              fontSize: Dimensions.font20 * 0.95,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: Dimensions.height10 / 2.5),
          Text(
            order.salesOrderNumber,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardWrapper(BuildContext context, Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: Dimensions.radius15 * 0.53,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Dimensions.font16 * 0.7,
        fontWeight: FontWeight.w700,
        color: context.colors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return _cardWrapper(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'ORDER INFORMATION'),
          SizedBox(height: Dimensions.height15),
          DetailRow(
            label: 'Reference#:',
            value: order.referenceNumber.isEmpty ? '—' : order.referenceNumber,
          ),
          if (order.expectedShipmentDate != null) ...[
            SizedBox(height: Dimensions.height15),
            DetailRow(
              label: 'Expected Shipment:',
              value: formatDate(order.expectedShipmentDate!),
            ),
          ],
          SizedBox(height: Dimensions.height15),
          DetailRow(label: 'Payment Terms:', value: order.paymentTerms),
          if (order.deliveryMethod.isNotEmpty) ...[
            SizedBox(height: Dimensions.height15),
            DetailRow(label: 'Delivery Method:', value: order.deliveryMethod),
          ],
          if (order.salesperson.isNotEmpty) ...[
            SizedBox(height: Dimensions.height15),
            DetailRow(label: 'Salesperson:', value: order.salesperson),
          ],
        ],
      ),
    );
  }

  Widget _buildLineItemsCard(BuildContext context) {
    return _cardWrapper(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'ITEMS'),
          SizedBox(height: Dimensions.height15),
          if (order.lineItems.isEmpty)
            Text(
              'No items added.',
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.85,
                color: context.colors.textTertiary,
              ),
            )
          else
            ...List.generate(order.lineItems.length, (i) {
              final line = order.lineItems[i];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i == order.lineItems.length - 1
                      ? 0
                      : Dimensions.height15,
                ),
                child: _buildLineItemRow(context, line),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLineItemRow(BuildContext context, SalesOrderLineItem line) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.itemName,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.9,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (line.description.isNotEmpty) ...[
                    SizedBox(height: Dimensions.height10 / 3),
                    Text(
                      line.description,
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.75,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                  SizedBox(height: Dimensions.height10 / 2),
                  Text(
                    '${_qtyText(line.quantity)} × ${_currency.format(line.rate)}'
                    '${line.discount > 0 ? '  •  -${line.discountIsPercent ? '${_qtyText(line.discount)}%' : _currency.format(line.discount)}' : ''}'
                    '${line.taxRate > 0 ? '  •  ${_qtyText(line.taxRate)}% tax' : ''}',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.75,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: Dimensions.width10),
            Text(
              _currency.format(line.total),
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.9,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalsCard(BuildContext context) {
    return _cardWrapper(
      context,
      Column(
        children: [
          _totalRow(context, 'Sub Total', _currency.format(order.subTotal)),
          SizedBox(height: Dimensions.height10),
          _totalRow(context, 'Tax', _currency.format(order.taxAmount)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
            child: Divider(height: 1, color: context.colors.border),
          ),
          _totalRow(
            context,
            'Total',
            _currency.format(order.total),
            emphasize: true,
          ),
        ],
      ),
    );
  }

  Widget _totalRow(
    BuildContext context,
    String label,
    String value, {
    bool emphasize = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: emphasize ? Dimensions.font16 : Dimensions.font16 * 0.85,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
            color: emphasize
                ? context.colors.textPrimary
                : context.colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasize ? Dimensions.font20 * 0.95 : Dimensions.font16,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
            color: emphasize ? AppColors.primary : context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(BuildContext context, String title, String body) {
    return _cardWrapper(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, title.toUpperCase()),
          SizedBox(height: Dimensions.height10),
          Text(
            body,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              height: 1.5,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _qtyText(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}
