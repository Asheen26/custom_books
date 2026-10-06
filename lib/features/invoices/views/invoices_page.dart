import 'dart:async';

import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/active_filter_banner.dart';
import 'package:custom_books/core/widgets/custom_add_button.dart';
import 'package:custom_books/core/widgets/custom_search_field.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/empty_state_widget.dart';
import 'package:custom_books/core/widgets/list_control_bar.dart';
import 'package:custom_books/core/widgets/more_options_sheet.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/enums/sort_direction.dart';
import 'package:custom_books/features/drawer/views/custom_drawer.dart';
import 'package:custom_books/features/invoices/controllers/invoices_list_controller.dart';
import 'package:custom_books/features/invoices/models/invoice_model.dart';
import 'package:custom_books/features/invoices/views/new_invoice_page.dart';
import 'package:custom_books/features/invoices/widgets/invoices_page_widgets/invoice_filter_sheet.dart';
import 'package:custom_books/features/invoices/widgets/invoices_page_widgets/invoice_list_item.dart';
import 'package:custom_books/features/invoices/widgets/invoices_page_widgets/invoice_sort_sheet.dart';
import 'package:flutter/material.dart';

class InvoicesPage extends StatefulWidget {
  final int initialTab;

  const InvoicesPage({super.key, this.initialTab = 0});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final InvoicesListController _controller = InvoicesListController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  late int _selectedTab;
  bool _searchOpen = false;
  InvoiceStatus? _statusFilter;
  InvoiceSortField _sortField = InvoiceSortField.createdTime;
  SortDirection _sortDirection = SortDirection.descending;

  // ── tab → API status string mapping ──────────────────────────────────────
  static const _tabStatusKeys = [null, 'draft', 'overdue', 'paid'];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _controller.addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);
    _loadInvoices();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _controller.loadNextPage();
    }
  }

  /// Builds the effective API status param from the selected tab + filter chip.
  String? get _effectiveStatus {
    // Explicit filter chip takes priority over tab
    if (_statusFilter != null) return _statusApiKey(_statusFilter!);
    return _tabStatusKeys[_selectedTab];
  }

  String _statusApiKey(InvoiceStatus s) {
    switch (s) {
      case InvoiceStatus.draft:
        return 'draft';
      case InvoiceStatus.sent:
        return 'sent';
      case InvoiceStatus.paid:
        return 'paid';
      case InvoiceStatus.partiallyPaid:
        return 'partially_paid';
      case InvoiceStatus.overdue:
        return 'overdue';
      case InvoiceStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Maps the sort enum to the API field key.
  String _sortKey(InvoiceSortField field) {
    switch (field) {
      case InvoiceSortField.createdTime:
        return 'created_at';
      case InvoiceSortField.date:
        return 'invoice_date';
      case InvoiceSortField.invoiceNumber:
        return 'invoice_number';
      case InvoiceSortField.customerName:
        return 'customer_name';
      case InvoiceSortField.amount:
        return 'total_amount';
    }
  }

  Future<void> _loadInvoices() async {
    await _controller.loadFirstPage(
      status: _effectiveStatus,
      sortBy: _sortKey(_sortField),
      sortOrder: _sortDirection == SortDirection.ascending ? 'asc' : 'desc',
      search: _searchController.text.trim(),
    );
    if (!mounted) return;
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _loadInvoices);
  }

  Future<void> _addNewInvoice() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const NewInvoicePage()),
    );
    if (mounted) _loadInvoices();
  }

  void _showMoreOptions() {
    MoreOptionsSheet.show(
      context,
      sectionLabel: 'INVOICE ACTIONS',
      items: [
        MoreOptionsItem(
          icon: Icons.file_download_outlined,
          title: 'Export Invoices',
          subtitle: 'Export the current invoice list',
          onTap: () =>
              ToastificationHelper.showSuccess(context, 'Invoices exported'),
        ),
        MoreOptionsItem(
          icon: Icons.notifications_outlined,
          title: 'Send Payment Reminders',
          subtitle: 'Send reminders for overdue invoices',
          onTap: () => ToastificationHelper.showInfo(
            context,
            'Payment reminders is coming soon.',
          ),
        ),
        MoreOptionsItem(
          icon: Icons.refresh_rounded,
          title: 'Refresh',
          subtitle: 'Reload the latest invoices',
          onTap: () => _refreshKey.currentState?.show(),
        ),
      ],
    );
  }

  void _openFilterSheet() {
    InvoiceFilterSheet.show(
      context,
      selectedStatus: _statusFilter,
      onSelected: (status) {
        setState(() => _statusFilter = status);
        _loadInvoices();
      },
    );
  }

  void _openSortSheet() {
    InvoiceSortSheet.show(
      context,
      initialField: _sortField,
      initialDirection: _sortDirection,
      onApply: (field, direction) {
        setState(() {
          _sortField = field;
          _sortDirection = direction;
        });
        _loadInvoices();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    appLog('🏗️ Building InvoicesPage', name: 'InvoicesPage');
    final invoices = _controller.invoices;

    return Scaffold(
      backgroundColor: context.colors.background,
      drawer: const DrawerView(currentRoute: 'invoices'),
      floatingActionButton: CustomAddButton(onPressed: _addNewInvoice),
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshKey,
          color: AppColors.primary,
          backgroundColor: context.colors.card,
          strokeWidth: 2.5,
          onRefresh: _loadInvoices,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              CustomSliverAppBar(
                title: 'Invoices',
                subtitle:
                    '${_controller.totalCount} invoice${_controller.totalCount == 1 ? '' : 's'}',
                leadingType: AppBarLeadingType.menu,
                actions: [
                  AppBarIconButton(
                    icon: _searchOpen
                        ? Icons.close_rounded
                        : Icons.search_rounded,
                    onPressed: () => setState(() {
                      _searchOpen = !_searchOpen;
                      if (!_searchOpen) {
                        _searchController.clear();
                        _loadInvoices();
                      }
                    }),
                  ),
                  SizedBox(width: Dimensions.width10),
                  AppBarIconButton(
                    icon: Icons.more_vert_rounded,
                    color: AppColors.accent,
                    onPressed: _showMoreOptions,
                  ),
                  SizedBox(width: Dimensions.width20),
                ],
              ),

              // Search field
              if (_searchOpen)
                SliverToBoxAdapter(
                  child: ListSearchField(
                    controller: _searchController,
                    hintText: 'Search by customer or invoice number',
                    onChanged: _onSearchChanged,
                  ),
                ),

              // Tab bar + filter/sort controls
              SliverToBoxAdapter(
                child: ListControlBar(
                  tabs: const ['All', 'Draft', 'Overdue', 'Paid'],
                  selectedTab: _selectedTab,
                  onTabSelected: (index) {
                    setState(() {
                      _selectedTab = index;
                      _statusFilter = null;
                    });
                    _loadInvoices();
                  },
                  filterActive: _statusFilter != null,
                  onFilterTap: _openFilterSheet,
                  onSortTap: _openSortSheet,
                ),
              ),

              // Active filter banner
              if (_statusFilter != null)
                SliverToBoxAdapter(
                  child: ActiveFilterBanner(
                    label: 'Status: ${_statusFilter!.label}',
                    onClear: () {
                      setState(() => _statusFilter = null);
                      _loadInvoices();
                    },
                  ),
                ),

              // List content
              if (_controller.isLoading && invoices.isEmpty)
                const SliverToBoxAdapter(
                  child: DocumentListSkeleton(showSubDate: true),
                )
              else if (invoices.isEmpty)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: EmptyStateWidget(
                      icon: Icons.description_outlined,
                      title: 'No invoices found',
                      subtitle: 'Tap the + button to create a new invoice.',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    0,
                    Dimensions.width20,
                    Dimensions.listBottomSpace,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= invoices.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height20,
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: EdgeInsets.only(bottom: Dimensions.height10),
                          child: InvoiceListItem(
                            invoice: invoices[index],
                            onRefresh: _loadInvoices,
                          ),
                        );
                      },
                      childCount:
                          invoices.length + (_controller.isLoadingMore ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
