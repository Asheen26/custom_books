import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/banking/controllers/banking_overview_controller.dart';
import 'package:custom_books/features/banking/models/bank_account.dart';
import 'package:custom_books/features/banking/models/banking_overview.dart';
import 'package:custom_books/features/banking/views/account_transactions_page.dart';
import 'package:custom_books/features/banking/views/add_bank_account_page.dart';
import 'package:custom_books/features/banking/widgets/bank_account_card.dart';
import 'package:custom_books/core/widgets/more_options_sheet.dart';
import 'package:custom_books/features/banking/widgets/banking_summary_card.dart';
import 'package:custom_books/features/banking/widgets/active_account_item.dart';
import 'package:custom_books/features/banking/widgets/banking_filter_button.dart';
import 'package:custom_books/features/banking/widgets/banking_selection_sheet.dart';
import 'package:custom_books/features/drawer/views/custom_drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BankingPage extends StatefulWidget {
  const BankingPage({super.key});

  @override
  State<BankingPage> createState() => _BankingPageState();
}

class _BankingPageState extends State<BankingPage> {
  final BankingOverviewController _controller = BankingOverviewController();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  // Currently selected filter keys (API keys, not labels).
  String _selectedAccountId = 'all';
  String _selectedDateRange = 'last_30_days';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _loadOverview();
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

  Future<void> _loadOverview() async {
    await _controller.load(
      dateRange: _selectedDateRange,
      accountId: _selectedAccountId,
    );
    if (!mounted) return;
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  bool get _isLoading => _controller.isLoading;
  BankingOverview? get _overview => _controller.overview;

  double get _cashInHand => _overview?.cashInHand ?? 0.0;
  double get _bankBalance => _overview?.bankBalance ?? 0.0;
  List<BankAccount> get _accounts => _overview?.accounts ?? const [];

  /// Convert the API chart points into fl_chart spots (indexed by position).
  List<FlSpot> get _chartData {
    final points = _overview?.chart ?? const [];
    return [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].balance),
    ];
  }

  String get _accountLabel {
    final label = _overview?.accountLabel;
    if (label != null && label.isNotEmpty) return label;
    return 'All Accounts';
  }

  String get _dateRangeLabel {
    final label = _overview?.dateRangeLabel;
    if (label != null && label.isNotEmpty) return label;
    return 'Last 30 days';
  }

  void _showAccountSheet() {
    final options = _overview?.accountOptions ?? const [];
    if (options.isEmpty) return;
    BankingSelectionSheet.show(
      context,
      title: 'Select Account',
      options: options.map((o) => o.label).toList(),
      selectedOption: _accountLabel,
      onSelected: (label) {
        final match = options.firstWhere(
          (o) => o.label == label,
          orElse: () => options.first,
        );
        if (match.key != _selectedAccountId) {
          setState(() => _selectedAccountId = match.key);
          _loadOverview();
        }
      },
    );
  }

  void _showDateRangeSheet() {
    final options = _overview?.availableDateRanges ?? const [];
    if (options.isEmpty) return;
    BankingSelectionSheet.show(
      context,
      title: 'Select Date Range',
      options: options.map((o) => o.label).toList(),
      selectedOption: _dateRangeLabel,
      onSelected: (label) {
        final match = options.firstWhere(
          (o) => o.label == label,
          orElse: () => options.first,
        );
        if (match.key != _selectedDateRange) {
          setState(() => _selectedDateRange = match.key);
          _loadOverview();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      drawer: const DrawerView(currentRoute: 'banking'),
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshKey,
          color: AppColors.primary,
          backgroundColor: context.colors.card,
          strokeWidth: 2.5,
          onRefresh: _loadOverview,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // App Bar
              CustomSliverAppBar(
                title: _overview?.title ?? 'Banking Overview',
                subtitle:
                    _overview?.subtitle ?? 'Track your accounts & transactions',
                leadingType: AppBarLeadingType.menu,
                actions: [
                  AppBarIconButton(
                    icon: Icons.filter_list_rounded,
                    color: AppColors.primary,
                    onPressed: _showAccountSheet,
                  ),
                  SizedBox(width: Dimensions.width10),
                  AppBarIconButton(
                    icon: Icons.more_vert_rounded,
                    color: AppColors.accent,
                    onPressed: () {
                      MoreOptionsSheet.show(
                        context,
                        sectionLabel: 'BANKING ACTIONS',
                        items: [
                          MoreOptionsItem(
                            icon: Icons.file_download_outlined,
                            title: 'Export Statement',
                            subtitle: 'Export your bank account statement',
                            onTap: () => ToastificationHelper.showInfo(
                              context,
                              'Exporting statements is coming soon.',
                            ),
                          ),
                          MoreOptionsItem(
                            icon: Icons.refresh_rounded,
                            title: 'Refresh',
                            subtitle: 'Reload the latest banking data',
                            onTap: () {
                              // Trigger the same pull-to-refresh spinner so the
                              // user sees the reload happening.
                              _refreshKey.currentState?.show();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(width: Dimensions.width20),
                ],
              ),

              // Filter Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    0,
                    Dimensions.width20,
                    Dimensions.height15,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(Dimensions.width10 / 2),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceLight,
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: BankingFilterButton(
                            label: _accountLabel,
                            onTap: _showAccountSheet,
                          ),
                        ),
                        SizedBox(width: Dimensions.width10 * 0.4),
                        Expanded(
                          child: BankingFilterButton(
                            label: _dateRangeLabel,
                            icon: Icons.calendar_today_rounded,
                            onTap: _showDateRangeSheet,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Account Summary Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    0,
                    Dimensions.width20,
                    Dimensions.height20,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: BankAccountCard(
                          icon: Icons.payments_rounded,
                          iconBgColor: AppColors.primary,
                          title: 'Cash In Hand',
                          amount: '₹${_cashInHand.toStringAsFixed(2)}',
                        ),
                      ),
                      SizedBox(width: Dimensions.width15),
                      Expanded(
                        child: BankAccountCard(
                          icon: Icons.account_balance_rounded,
                          iconBgColor: AppColors.success,
                          title: 'Bank Balance',
                          amount: '₹${_bankBalance.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Banking Summary Chart
              SliverToBoxAdapter(
                child: BankingSummaryCard(
                  chartData: _chartData,
                  cashInHand: _cashInHand,
                  bankBalance: _bankBalance,
                ),
              ),

              // Active Accounts Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    Dimensions.height20,
                    Dimensions.width20,
                    Dimensions.height15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Accounts',
                        style: TextStyle(
                          fontSize: Dimensions.font20 * 0.95,
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_accounts.length} accounts',
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.75,
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Active Accounts List
              if (_isLoading && _overview == null)
                const SliverToBoxAdapter(child: DocumentListSkeleton())
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ActiveAccountItem(
                        account: _accounts[index],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AccountTransactionsPage(
                              account: _accounts[index],
                            ),
                          ),
                        ),
                      ),
                      childCount: _accounts.length,
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: Dimensions.height30 + Dimensions.listBottomSpace,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const AddBankAccountPage()),
          );
          if (created == true) _loadOverview();
        },
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius20),
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: Dimensions.iconSize24 * 1.2,
        ),
      ),
    );
  }
}
