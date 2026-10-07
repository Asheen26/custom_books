import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/features/payments_received/controllers/payment_received_detail_controller.dart';
import 'package:custom_books/features/payments_received/models/payment_received_model.dart';
import 'package:custom_books/features/payments_received/models/payments_received_options_model.dart';
import 'package:custom_books/features/payments_received/views/add_payment_received_page.dart';
import 'package:flutter/material.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';

class PaymentReceivedDetailsPage extends StatefulWidget {
  /// Lightweight model passed from the list page — used to seed the UI
  /// immediately while the full detail fetch runs in the background.
  final PaymentReceivedModel payment;

  /// Actions list from the options API — drives the popup menu.
  final List<PaymentReceivedAction> actions;

  const PaymentReceivedDetailsPage({
    super.key,
    required this.payment,
    this.actions = const [],
  });

  @override
  State<PaymentReceivedDetailsPage> createState() =>
      _PaymentReceivedDetailsPageState();
}

class _PaymentReceivedDetailsPageState extends State<PaymentReceivedDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final PaymentReceivedDetailController _ctrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ctrl = PaymentReceivedDetailController();
    _ctrl.addListener(_onCtrlUpdate);
    _loadPayment();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ctrl.removeListener(_onCtrlUpdate);
    _ctrl.dispose();
    super.dispose();
  }

  void _onCtrlUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _loadPayment() async {
    await _ctrl.load(widget.payment.id, seed: widget.payment);
    if (!mounted) return;
    if (_ctrl.errorMessage != null) {
      ToastificationHelper.showError(context, _ctrl.errorMessage!);
    }
  }

  // ── action helpers ────────────────────────────────────────────────────────

  String _actionLabel(String key) {
    for (final a in widget.actions) {
      if (a.key == key) return a.label;
    }
    return key;
  }

  static IconData _iconForAction(String key) {
    switch (key) {
      case 'save':
        return Icons.save_outlined;
      case 'edit':
        return Icons.edit_rounded;
      case 'delete':
        return Icons.delete_outline_rounded;
      case 'print':
        return Icons.print_rounded;
      case 'download_pdf':
        return Icons.picture_as_pdf_outlined;
      case 'preview':
        return Icons.visibility_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'void':
        return Icons.block_rounded;
      case 'apply':
        return Icons.link_rounded;
      case 'unapply':
        return Icons.link_off_rounded;
      case 'history':
        return Icons.history_rounded;
      case 'change_template':
        return Icons.dashboard_customize_outlined;
      case 'export':
        return Icons.file_download_outlined;
      case 'refresh':
        return Icons.refresh_rounded;
      default:
        return Icons.arrow_forward_ios_rounded;
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Use the full detail model once loaded, otherwise fall back to the seed.
    final payment = _ctrl.payment ?? widget.payment;
    const statusColor = AppColors.success;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomBackAppBar(
        title: 'Payment Details',
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
                builder: (_) => AddPaymentReceivedPage(existing: payment),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.email_outlined,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            onPressed: () => ToastificationHelper.showInfo(
              context,
              'Send Email is coming soon.',
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
            onSelected: (key) async {
              if (key == 'delete') {
                final confirmed = await showConfirmationDialog(
                  context,
                  title: 'Delete Payment',
                  message:
                      'Are you sure you want to delete this payment? This action cannot be undone.',
                );
                if (!confirmed || !context.mounted) return;
                final error = await _ctrl.deletePayment(payment.id);
                if (!context.mounted) return;
                if (error == null) {
                  ToastificationHelper.showSuccess(
                    context,
                    '${payment.paymentNumber} deleted successfully.',
                  );
                  Navigator.pop(context, true); // signal list to refresh
                } else {
                  ToastificationHelper.showError(context, error);
                }
              } else if (key == 'void') {
                final confirmed = await showConfirmationDialog(
                  context,
                  title: 'Void Payment',
                  message:
                      'Are you sure you want to void ${payment.paymentNumber}? This action cannot be undone.',
                );
                if (!confirmed || !context.mounted) return;
                final error = await _ctrl.voidPayment(payment.id);
                if (!context.mounted) return;
                if (error == null) {
                  ToastificationHelper.showSuccess(
                    context,
                    _ctrl.payment != null
                        ? '${_ctrl.payment!.paymentNumber} has been voided.'
                        : '${payment.paymentNumber} has been voided.',
                  );
                } else {
                  ToastificationHelper.showError(context, error);
                }
              } else if (key == 'edit') {
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPaymentReceivedPage(existing: payment),
                  ),
                );
              } else {
                ToastificationHelper.showInfo(
                  context,
                  '${_actionLabel(key)} is coming soon.',
                );
              }
            },
            itemBuilder: (context) {
              // 'edit' and 'email' are dedicated IconButtons; 'apply', 'unapply',
              // 'history', 'change_template' are hidden until their APIs are connected.
              const hiddenKeys = {
                'edit',
                'email',
                'apply',
                'unapply',
                'history',
                'change_template',
              };
              final rawItems = widget.actions.isNotEmpty
                  ? widget.actions
                        .where((a) => !hiddenKeys.contains(a.key))
                        .toList()
                  : const [
                      PaymentReceivedAction(
                        key: 'print',
                        label: 'Print',
                        path: '',
                      ),
                      PaymentReceivedAction(
                        key: 'delete',
                        label: 'Delete',
                        path: '',
                      ),
                    ];
              final items = rawItems;

              return items.map((action) {
                final bool isDanger =
                    action.key == 'delete' || action.key == 'void';
                return PopupMenuItem<String>(
                  value: action.key,
                  child: Row(
                    children: [
                      Icon(
                        _iconForAction(action.key),
                        size: Dimensions.iconSize16 + 4,
                        color: isDanger
                            ? AppColors.warn
                            : context.colors.textSecondary,
                      ),
                      SizedBox(width: Dimensions.width10),
                      Text(
                        action.label,
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.85,
                          fontWeight: FontWeight.w600,
                          color: isDanger
                              ? AppColors.warn
                              : context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          SizedBox(width: Dimensions.width10),
        ],
      ),
      body: SafeArea(
        child: _ctrl.isLoading && _ctrl.payment == null
            ? const DetailsPageSkeleton()
            : Column(
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Dimensions.width20),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
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
                              'Date',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.7,
                                color: context.colors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Status badge — driven by API receipt_status_label
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.width10 + 2,
                                vertical: Dimensions.height10 * 0.5,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radius30,
                                ),
                              ),
                              child: Text(
                                payment.receiptStatusLabel.isNotEmpty
                                    ? payment.receiptStatusLabel
                                    : 'PAID',
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
                          payment.paymentDateLabel.isNotEmpty
                              ? payment.paymentDateLabel
                              : formatDate(payment.paymentDate),
                          style: TextStyle(
                            fontSize: Dimensions.font20 * 0.95,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),
                        Text(
                          payment.customerName,
                          style: TextStyle(
                            fontSize: Dimensions.font20 * 0.95,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: Dimensions.height10 / 2.5),
                        Text(
                          payment.paymentNumber,
                          style: TextStyle(
                            fontSize: Dimensions.font16 * 0.85,
                            color: context.colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height15),

                  // ── Tab bar ───────────────────────────────────────────────
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
                            blurRadius: 8,
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

                  // ── Tab content ───────────────────────────────────────────
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDetailsTab(payment),
                        _buildCommentsTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Details tab ───────────────────────────────────────────────────────────

  Widget _buildDetailsTab(PaymentReceivedModel payment) {
    final summary = payment.amountSummary;

    String fmt(double v) =>
        '${payment.currency.isNotEmpty ? payment.currency : '₹'} ${v.toStringAsFixed(2)}';

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        // ── Core fields card ──────────────────────────────────────────
        _card(
          children: [
            DetailRow(label: 'Payment Mode:', value: payment.mode.label),
            SizedBox(height: Dimensions.height15),
            DetailRow(
              label: 'Reference#:',
              value: payment.referenceNumber.isEmpty
                  ? '-'
                  : payment.referenceNumber,
            ),
            SizedBox(height: Dimensions.height15),
            DetailRow(
              label: 'Status:',
              value: payment.statusLabel.isNotEmpty
                  ? payment.statusLabel
                  : payment.status,
            ),
            SizedBox(height: Dimensions.height15),
            DetailRow(
              label: 'Applied to Invoices:',
              value: payment.invoiceNumbers.isEmpty
                  ? 'Unapplied'
                  : payment.invoiceNumbers.join(', '),
            ),
            if (payment.notes.isNotEmpty) ...[
              SizedBox(height: Dimensions.height15),
              DetailRow(label: 'Notes:', value: payment.notes),
            ],
          ],
        ),
        SizedBox(height: Dimensions.height15),

        // ── Amount summary card ───────────────────────────────────────
        _card(
          children: [
            _sectionTitle('Amount Summary'),
            SizedBox(height: Dimensions.height15),
            DetailRow(
              label: 'Amount Received:',
              value: fmt(summary.amountReceived),
            ),
            if (summary.bankCharges > 0) ...[
              SizedBox(height: Dimensions.height15),
              DetailRow(
                label: 'Bank Charges:',
                value: fmt(summary.bankCharges),
              ),
            ],
            SizedBox(height: Dimensions.height15),
            DetailRow(
              label: 'Used for Payments:',
              value: fmt(summary.amountUsedForPayments),
            ),
            SizedBox(height: Dimensions.height15),
            DetailRow(
              label: 'Amount Refunded:',
              value: fmt(summary.amountRefunded),
            ),
            SizedBox(height: Dimensions.height15),
            const Divider(height: 1),
            SizedBox(height: Dimensions.height15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount in Excess:',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.78,
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  fmt(summary.amountInExcess),
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.95,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: Dimensions.height30),
      ],
    );
  }

  // ── Comments tab ──────────────────────────────────────────────────────────

  Widget _buildCommentsTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Dimensions.width20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(Dimensions.width20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: Dimensions.iconSize24 * 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'No comments or history yet',
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.95,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              'Comments and activity history\nwill appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.8,
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Dimensions.font16 * 0.78,
        fontWeight: FontWeight.w800,
        color: context.colors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }
}
