import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/features/sales_orders/models/sales_order_model.dart';
import 'package:custom_books/features/sales_orders/viewmodels/sales_orders_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:custom_books/core/utils/date_formatter.dart';

class SalesOrderActionsSheet extends StatefulWidget {
  final SalesOrderModel order;
  final ValueChanged<SalesOrderStatus> onStatusChanged;
  final VoidCallback onDelete;

  const SalesOrderActionsSheet({
    super.key,
    required this.order,
    required this.onStatusChanged,
    required this.onDelete,
  });

  @override
  State<SalesOrderActionsSheet> createState() => _SalesOrderActionsSheetState();
}

class _SalesOrderActionsSheetState extends State<SalesOrderActionsSheet> {
  final _vm = SalesOrdersListViewModel();
  bool _isLoading = false;

  Future<void> _runAction(String action) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final Future<Map<String, dynamic>?> call;
    switch (action) {
      case 'confirm':
        call = _vm.confirmSalesOrder(widget.order.id);
      case 'cancel':
        call = _vm.cancelSalesOrder(widget.order.id);
      case 'mark_invoiced':
        call = _vm.markSalesOrderInvoiced(widget.order.id);
      default:
        setState(() => _isLoading = false);
        return;
    }

    final resp = await call;
    if (!mounted) return;

    Navigator.pop(context);

    final int? statusCode = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        final updated = SalesOrderModel.fromJson(data);
        widget.onStatusChanged(updated.status);
        final msg = (resp['message'] ?? 'Status updated.').toString();
        ToastificationHelper.showSuccess(context, msg);
        appLog(
          'Sales Order $action success: ${widget.order.salesOrderNumber} -> ${updated.status}',
          name: 'SalesOrderActionsSheet',
        );
      }
    } else {
      final msg =
          (resp?['message'] ?? 'Action failed. Please try again.').toString();
      ToastificationHelper.showError(context, msg);
      appLog(
        'Sales Order $action failed (status: $statusCode): $msg',
        name: 'SalesOrderActionsSheet',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          Dimensions.height10,
          Dimensions.width20,
          Dimensions.height20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.order.salesOrderNumber,
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10,
                    vertical: Dimensions.height10 / 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.order.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                  child: Text(
                    widget.order.status.label,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.75,
                      fontWeight: FontWeight.w700,
                      color: widget.order.status.color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              widget.order.customerName,
              style: TextStyle(
                fontSize: Dimensions.font16,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: Dimensions.height10 / 2),
            Text(
              'Date: ${formatDate(widget.order.salesOrderDate)} | Total: ${currencyFormat.format(widget.order.total)}',
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.8,
                color: context.colors.textSecondary,
              ),
            ),
            Divider(
                height: Dimensions.height20 * 1.5,
                color: context.colors.border),

            // Show a loading indicator while an action is in progress
            if (_isLoading)
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: Dimensions.height20),
                child: const Center(child: CircularProgressIndicator.adaptive()),
              )
            else ...[
              if (widget.order.status == SalesOrderStatus.draft)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline_rounded,
                      color: Colors.green),
                  title: const Text('Mark as Confirmed'),
                  onTap: () => _runAction('confirm'),
                ),
              if (widget.order.status == SalesOrderStatus.confirmed)
                ListTile(
                  leading: const Icon(Icons.receipt_long_rounded,
                      color: AppColors.primary),
                  title: const Text('Mark as Invoiced'),
                  onTap: () => _runAction('mark_invoiced'),
                ),
              if (widget.order.status == SalesOrderStatus.draft ||
                  widget.order.status == SalesOrderStatus.confirmed)
                ListTile(
                  leading:
                      const Icon(Icons.cancel_outlined, color: Colors.orange),
                  title: const Text('Cancel Order',
                      style: TextStyle(color: Colors.orange)),
                  onTap: () => _runAction('cancel'),
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red),
                title: const Text('Delete Sales Order',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
