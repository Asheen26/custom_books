import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/customers/widgets/customer_details_page_widgets/comments_tab.dart';
import 'package:custom_books/features/payments_received/controllers/payment_received_detail_controller.dart';
import 'package:custom_books/features/payments_received/models/payment_received_model.dart';
import 'package:custom_books/features/payments_received/models/payments_received_options_model.dart';
import 'package:custom_books/features/payments_received/views/add_payment_received_page.dart';
import 'package:custom_books/features/payments_received/widgets/payment_received_details_header.dart';
import 'package:custom_books/features/payments_received/widgets/payment_received_details_tab.dart';
import 'package:flutter/material.dart';

class PaymentReceivedDetailsPage extends StatefulWidget {
  final PaymentReceivedModel payment;
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
    _ctrl.addListener(_rebuild);
    _loadPayment();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ctrl.removeListener(_rebuild);
    _ctrl.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _loadPayment() async {
    await _ctrl.load(widget.payment.id, seed: widget.payment);
    if (!mounted) return;
    if (_ctrl.errorMessage != null) {
      ToastificationHelper.showError(context, _ctrl.errorMessage!);
    }
  }

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
      default:
        return Icons.arrow_forward_ios_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = _ctrl.payment ?? widget.payment;

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
                  Navigator.pop(context, true);
                } else {
                  ToastificationHelper.showError(context, error);
                }
              } else if (key == 'void') {
                final confirmed = await showConfirmationDialog(
                  context,
                  title: 'Void Payment',
                  message:
                      'Are you sure you want to void ${payment.paymentNumber}?',
                );
                if (!confirmed || !context.mounted) return;
                final error = await _ctrl.voidPayment(payment.id);
                if (!context.mounted) return;
                if (error == null) {
                  ToastificationHelper.showSuccess(
                    context,
                    '${payment.paymentNumber} has been voided.',
                  );
                } else {
                  ToastificationHelper.showError(context, error);
                }
              } else if (key == 'edit') {
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
              return rawItems.map((action) {
                final isDanger = action.key == 'delete' || action.key == 'void';
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
                  PaymentReceivedDetailsHeader(payment: payment),
                  SizedBox(height: Dimensions.height15),
                  _pillTabBar(),
                  SizedBox(height: Dimensions.height15),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        PaymentReceivedDetailsTab(payment: payment),
                        const CommentsTab(),
                      ],
                    ),
                  ),
                ],
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
    );
  }
}
