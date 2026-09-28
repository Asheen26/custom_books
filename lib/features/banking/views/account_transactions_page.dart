import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/more_options_sheet.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/features/banking/controllers/bank_transactions_controller.dart';
import 'package:custom_books/features/banking/models/bank_account.dart';
import 'package:custom_books/features/banking/models/bank_transaction.dart';
import 'package:custom_books/features/banking/views/bank_transaction_details_page.dart';
import 'package:custom_books/features/banking/widgets/bank_transaction_tile.dart';
import 'package:custom_books/features/banking/widgets/banking_selection_sheet.dart';
import 'package:flutter/material.dart';

/// The kind of transactions shown in the account history list.
enum _TxnFilter { all, deposits, withdrawals }

extension _TxnFilterLabel on _TxnFilter {
  String get label {
    switch (this) {
      case _TxnFilter.all:
        return 'All';
      case _TxnFilter.deposits:
        return 'Deposits';
      case _TxnFilter.withdrawals:
        return 'Withdrawals';
    }
  }
}

/// Shows the transaction history for a single [BankAccount].
///
/// Reached by tapping an account on the Banking overview screen. Tapping a
/// transaction opens [BankTransactionDetailsPage].
class AccountTransactionsPage extends StatefulWidget {
  final BankAccount account;

  const AccountTransactionsPage({super.key, required this.account});

  @override
  State<AccountTransactionsPage> createState() =>
      _AccountTransactionsPageState();
}

class _AccountTransactionsPageState extends State<AccountTransactionsPage> {
  late final BankTransactionsController _controller =
      BankTransactionsController(
        widget.account.id,
        fallbackCurrency: widget.account.currency,
      );
  _TxnFilter _filter = _TxnFilter.all;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    await _controller.load();
    if (!mounted) return;
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  bool get _isLoading => _controller.isLoading;

  /// Client-side deposit/withdrawal filtering over the fetched transactions.
  List<BankTransaction> get _visible {
    final all = _controller.transactions;
    switch (_filter) {
      case _TxnFilter.all:
        return all;
      case _TxnFilter.deposits:
        return all.where((t) => t.isCredit).toList();
      case _TxnFilter.withdrawals:
        return all.where((t) => !t.isCredit).toList();
    }
  }

  void _showFilterSheet() {
    BankingSelectionSheet.show(
      context,
      title: 'Filter Transactions',
      options: _TxnFilter.values.map((f) => f.label).toList(),
      selectedOption: _filter.label,
      onSelected: (label) {
        final match = _TxnFilter.values.firstWhere(
          (f) => f.label == label,
          orElse: () => _TxnFilter.all,
        );
        if (match != _filter) setState(() => _filter = match);
      },
    );
  }

  void _showMoreOptions() {
    MoreOptionsSheet.show(
      context,
      sectionLabel: 'TRANSACTION ACTIONS',
      items: [
        MoreOptionsItem(
          icon: Icons.file_download_outlined,
          title: 'Export Statement',
          subtitle: 'Export this account statement',
          onTap: () => ToastificationHelper.showInfo(
            context,
            'Exporting statements is coming soon.',
          ),
        ),
        MoreOptionsItem(
          icon: Icons.refresh_rounded,
          title: 'Refresh',
          subtitle: 'Reload the latest transactions',
          onTap: _load,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomBackAppBar(
        title: widget.account.name,
        backgroundColor: context.colors.card,
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            onPressed: _showMoreOptions,
          ),
          SizedBox(width: Dimensions.width10),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Filter dropdown row ("All ▼") ──────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height10,
              ),
              decoration: BoxDecoration(
                color: context.colors.card,
                border: Border(
                  bottom: BorderSide(color: context.colors.border),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: _showFilterSheet,
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width10 / 2,
                        vertical: Dimensions.height10 / 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _filter.label,
                            style: TextStyle(
                              fontSize: Dimensions.font16 * 0.9,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          SizedBox(width: Dimensions.width10 / 2),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: Dimensions.iconSize24 - 2,
                            color: context.colors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${visible.length} txn${visible.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.72,
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ── Transaction list ───────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const DocumentListSkeleton()
                  : visible.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: context.colors.card,
                      strokeWidth: 2.5,
                      onRefresh: _load,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final txn = visible[index];
                          return BankTransactionTile(
                            transaction: txn,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BankTransactionDetailsPage(
                                  transaction: txn,
                                  accountName: widget.account.name,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                Icons.receipt_long_rounded,
                size: Dimensions.iconSize24 * 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'No transactions found',
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.95,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              'Transactions for this account will\nappear here.',
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
}
