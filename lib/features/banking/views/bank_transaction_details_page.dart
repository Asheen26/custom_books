import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/features/banking/models/bank_transaction.dart';
import 'package:flutter/material.dart';

/// Details view for a single bank transaction.
///
/// Follows the tabbed layout of the inventory adjustment details page:
/// a header summary, then a DETAILS / PAYMENT HISTORY tab pair.
class BankTransactionDetailsPage extends StatefulWidget {
  final BankTransaction transaction;

  /// The account the transaction belongs to (used as a fallback deposit label).
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

class _BankTransactionDetailsPageState
    extends State<BankTransactionDetailsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  BankTransaction get _txn => widget.transaction;

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
    final txn = _txn;
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
                      'Are you sure you want to delete this transaction? '
                      'This action cannot be undone.',
                );
                if (confirmed && context.mounted) Navigator.pop(context);
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
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: Dimensions.height15),
            _buildTabs(),
            SizedBox(height: Dimensions.height15),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildDetailsTab(), _buildPaymentHistoryTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final txn = _txn;
    final amountColor = txn.isCredit ? AppColors.success : AppColors.warn;

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
          // Reference number + status chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  txn.referenceNumber?.isNotEmpty == true
                      ? txn.referenceNumber!
                      : txn.type,
                  style: TextStyle(
                    fontSize: Dimensions.font20 * 0.95,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              if (txn.status != null && txn.status!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width10 + 2,
                    vertical: Dimensions.height10 * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Dimensions.radius30),
                  ),
                  child: Text(
                    txn.status!.toUpperCase(),
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.62,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          if (txn.party != null && txn.party!.isNotEmpty) ...[
            SizedBox(height: Dimensions.height10 / 2.5),
            Text(
              txn.party!,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.85,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ],
          SizedBox(height: Dimensions.height20),

          // Amount
          Text(
            txn.isCredit ? 'Amount Received' : 'Amount Paid',
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.72,
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Dimensions.height10 / 2.5),
          Text(
            '${txn.currency}${txn.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: Dimensions.font26 * 0.9,
              fontWeight: FontWeight.w800,
              color: amountColor,
            ),
          ),
          SizedBox(height: Dimensions.height15),

          // Meta rows
          _headerMetaRow('Payment Date', formatDate(txn.date)),
          if (txn.referenceNumber != null &&
              txn.referenceNumber!.isNotEmpty) ...[
            SizedBox(height: Dimensions.height10),
            _headerMetaRow('Reference#', txn.referenceNumber!),
          ],
          if (txn.paymentMode != null && txn.paymentMode!.isNotEmpty) ...[
            SizedBox(height: Dimensions.height10),
            _headerMetaRow('Payment Mode', txn.paymentMode!),
          ],
        ],
      ),
    );
  }

  Widget _headerMetaRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:  ',
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.78,
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.82,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Tabs ─────────────────────────────────────────────────────────────
  Widget _buildTabs() {
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

  // ── Details tab ────────────────────────────────────────────────────────
  Widget _buildDetailsTab() {
    final txn = _txn;
    final hasInvoice = txn.invoiceNumber != null &&
        txn.invoiceNumber!.isNotEmpty;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        // Invoice / Payment amount section
        if (hasInvoice)
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Invoice Details',
                      style: _sectionLabelStyle(),
                    ),
                    Text(
                      'Payment Amount',
                      style: _sectionLabelStyle(),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height10),
                Divider(height: 1, color: context.colors.border),
                SizedBox(height: Dimensions.height15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.invoiceNumber!,
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.95,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${txn.currency}${txn.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.95,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height10),
                if (txn.invoiceDate != null)
                  DetailRow(
                    label: 'Invoice Date:',
                    value: formatDate(txn.invoiceDate!),
                  ),
                if (txn.invoiceAmount != null) ...[
                  SizedBox(height: Dimensions.height10),
                  DetailRow(
                    label: 'Invoice Amount:',
                    value:
                        '${txn.currency}${txn.invoiceAmount!.toStringAsFixed(2)}',
                  ),
                ],
              ],
            ),
          ),
        if (hasInvoice) SizedBox(height: Dimensions.height15),

        // Transaction info (for non-invoice transactions, e.g. Journal)
        if (!hasInvoice)
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transaction Details', style: _sectionTitleStyle()),
                SizedBox(height: Dimensions.height15),
                DetailRow(label: 'Type:', value: txn.type),
                SizedBox(height: Dimensions.height15),
                DetailRow(
                  label: 'Amount:',
                  value: '${txn.currency}${txn.amount.toStringAsFixed(2)}',
                ),
                SizedBox(height: Dimensions.height15),
                DetailRow(
                  label: 'Date:',
                  value: formatDate(txn.date),
                ),
                SizedBox(height: Dimensions.height15),
                DetailRow(label: 'Source:', value: txn.source),
              ],
            ),
          ),
        if (!hasInvoice) SizedBox(height: Dimensions.height15),

        // More Information section
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('More Information', style: _sectionTitleStyle()),
              SizedBox(height: Dimensions.height15),
              _infoBlock(
                'Deposit To',
                txn.depositTo?.isNotEmpty == true
                    ? txn.depositTo!
                    : widget.accountName,
              ),
              SizedBox(height: Dimensions.height15),
              _infoBlock(
                'Notes',
                txn.notes?.isNotEmpty == true
                    ? txn.notes!
                    : 'No notes provided.',
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.height15),

        // Template section
        if (txn.template != null && txn.template!.isNotEmpty)
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Template',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.72,
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: Dimensions.height10 / 2),
                Row(
                  children: [
                    Text(
                      "'${txn.template}'",
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.88,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Text(
                      ' - ',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.88,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ToastificationHelper.showInfo(
                        context,
                        'Changing template is coming soon.',
                      ),
                      child: Text(
                        'Change',
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.88,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        SizedBox(height: Dimensions.height30),
      ],
    );
  }

  // ── Payment history tab ──────────────────────────────────────────────
  Widget _buildPaymentHistoryTab() {
    final txn = _txn;
    return ListView(
      padding: EdgeInsets.all(Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        _card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Dimensions.height45 * 0.8,
                height: Dimensions.height45 * 0.8,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: Dimensions.iconSize24 - 6,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.isCredit
                          ? 'Payment of ${txn.currency}${txn.amount.toStringAsFixed(2)} received'
                          : 'Payment of ${txn.currency}${txn.amount.toStringAsFixed(2)} recorded',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.85,
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10 / 2),
                    Text(
                      '${txn.source}  •  ${formatDate(txn.date)}',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.7,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Shared building blocks ─────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
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

  Widget _infoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.72,
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: Dimensions.height10 / 2),
        Text(
          value,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.85,
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  TextStyle _sectionTitleStyle() => TextStyle(
    fontSize: Dimensions.font16 * 0.95,
    fontWeight: FontWeight.w800,
    color: context.colors.textPrimary,
  );

  TextStyle _sectionLabelStyle() => TextStyle(
    fontSize: Dimensions.font16 * 0.78,
    fontWeight: FontWeight.w600,
    color: context.colors.textSecondary,
  );
}
