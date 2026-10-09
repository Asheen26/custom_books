import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/features/banking/models/bank_transaction.dart';
import 'package:custom_books/features/banking/widgets/bank_txn_details_header.dart';
import 'package:custom_books/features/banking/widgets/bank_txn_details_tab.dart';
import 'package:custom_books/features/banking/widgets/bank_txn_payment_history_tab.dart';
import 'package:flutter/material.dart';

class BankTransactionDetailsPage extends StatefulWidget {
  final BankTransaction transaction;
  final String accountName;

  const BankTransactionDetailsPage({
    super.key,
    required this.transaction,
    required this.accountName,
  });

  @override
  State<BankTransactionDetailsPage> createState() =>
      _BankTransactionDetailsPageState();
}

class _BankTransactionDetailsPageState extends State<BankTransactionDetailsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txn = widget.transaction;
    final headerTitle = txn.referenceType ?? txn.type;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomBackAppBar(
        title: headerTitle,
        backgroundColor: context.colors.card,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            onPressed: () => ToastificationHelper.showInfo(
              context,
              'Editing transactions is coming soon.',
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.mail_outline_rounded,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            onPressed: () => ToastificationHelper.showInfo(
              context,
              'Emailing receipts is coming soon.',
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
            onSelected: (value) async {
              if (value == 'print') {
                ToastificationHelper.showInfo(
                  context,
                  'Generating PDF for print...',
                );
              } else if (value == 'delete') {
                final confirmed = await showConfirmationDialog(
                  context,
                  title: 'Delete Transaction',
                  message:
                      'Are you sure you want to delete this transaction? This action cannot be undone.',
                );
                if (confirmed && context.mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
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
          ),
          SizedBox(width: Dimensions.width10),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            BankTxnDetailsHeader(transaction: txn),
            SizedBox(height: Dimensions.height15),
            _pillTabBar(),
            SizedBox(height: Dimensions.height15),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  BankTxnDetailsTab(
                    transaction: txn,
                    accountName: widget.accountName,
                  ),
                  BankTxnPaymentHistoryTab(transaction: txn),
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
          Tab(text: 'PAYMENT HISTORY'),
        ],
      ),
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
