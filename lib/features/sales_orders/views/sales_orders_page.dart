import 'dart:async';

import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/active_filter_banner.dart';
import 'package:custom_books/core/widgets/custom_add_button.dart';
import 'package:custom_books/core/widgets/custom_search_field.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/document_list_tile.dart';
import 'package:custom_books/core/widgets/empty_state_widget.dart';
import 'package:custom_books/core/widgets/filter_sheet.dart';
import 'package:custom_books/core/widgets/generic_sort_sheet.dart';
import 'package:custom_books/core/widgets/list_control_bar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/status_chip.dart';
import 'package:custom_books/features/drawer/views/custom_drawer.dart';
import 'package:custom_books/features/sales_orders/controllers/sales_orders_list_controller.dart';
import 'package:custom_books/features/sales_orders/models/sales_order_model.dart';
import 'package:custom_books/features/sales_orders/views/add_sales_order_page.dart';
import 'package:custom_books/features/sales_orders/views/sales_order_details_page.dart';
import 'package:custom_books/features/sales_orders/widgets/sales_order_actions_sheet.dart';
import 'package:custom_books/core/widgets/more_options_sheet.dart';
import 'package:flutter/material.dart';
import 'package:custom_books/core/enums/sort_direction.dart';

class SalesOrdersPage extends StatefulWidget {
  const SalesOrdersPage({super.key});

  @override
  State<SalesOrdersPage> createState() => _SalesOrdersPageState();
}

class _SalesOrdersPageState extends State<SalesOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  final SalesOrdersListController _controller = SalesOrdersListController();
  final ScrollController _scrollController = ScrollController();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  Timer? _searchDebounce;

  /// Maps tab index → API filter key (from options API)
  static const _tabFilterKeys = <int, String>{
    0: 'all',
    1: 'draft',
    2: 'confirmed',
  };

  int _selectedTab = 0;
  bool _searchOpen = false;

  // Status filter from filter sheet (key string, e.g. 'draft', 'invoiced')
  String? _statusFilterKey;
  String? _statusFilterLabel;

  // Sort state — kept in sync with controller
  SalesOrderSortField _sortField = SalesOrderSortField.createdTime;
  SortDirection _sortDirection = SortDirection.descending;

  String get _sortByKey => switch (_sortField) {
    SalesOrderSortField.createdTime => 'created_time',
    SalesOrderSortField.date => 'date',
    SalesOrderSortField.salesOrderNumber => 'sales_order_number',
    SalesOrderSortField.referenceNumber => 'reference_number',
    SalesOrderSortField.customerName => 'customer_name',
    SalesOrderSortField.amount => 'amount',
  };

  String get _sortOrderKey =>
      _sortDirection == SortDirection.ascending ? 'asc' : 'desc';

  String get _activeFilter => _tabFilterKeys[_selectedTab] ?? 'all';

  @override
  void initState() {
    super.initState();
    appLog('🎯 SalesOrdersPage initialized', name: 'SalesOrdersPage');
    _controller.addListener(_onControllerUpdate);
    _scrollController.addListener(_onScroll);
    _initLoad();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _controller.loadNextPage();
    }
  }

  /// First load: fetch options then the first page.
  Future<void> _initLoad() async {
    await _controller.loadOptions();
    if (!mounted) return;
    // Apply server default sort from options
    final opts = _controller.options;
    if (opts != null) {
      final defaultSort = opts.defaultSort;
      _sortField = _sortFieldFromKey(defaultSort.sortBy);
      _sortDirection = defaultSort.sortOrder == 'asc'
          ? SortDirection.ascending
          : SortDirection.descending;
    }
    await _loadOrders();
  }

  Future<void> _loadOrders() async {
    await _controller.loadFirstPage(
      filter: _statusFilterKey != null ? null : _activeFilter,
      status: _statusFilterKey,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      sortBy: _sortByKey,
      sortOrder: _sortOrderKey,
    );
    if (!mounted) return;
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce =
        Timer(const Duration(milliseconds: 400), _loadOrders);
  }

  SalesOrderSortField _sortFieldFromKey(String key) => switch (key) {
    'date' => SalesOrderSortField.date,
    'sales_order_number' => SalesOrderSortField.salesOrderNumber,
    'reference_number' => SalesOrderSortField.referenceNumber,
    'customer_name' => SalesOrderSortField.customerName,
    'amount' => SalesOrderSortField.amount,
    _ => SalesOrderSortField.createdTime,
  };

  Future<void> _addNewSalesOrder() async {
    final newOrder = await Navigator.push<SalesOrderModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddSalesOrderPage(
            orderSequence: _controller.totalCount + 1),
      ),
    );

    if (newOrder != null && mounted) {
      ToastificationHelper.showSuccess(
        context,
        '${newOrder.salesOrderNumber} created successfully',
      );
      // Refresh options (counts change) + list
      await _controller.loadOptions();
      if (mounted) {
        setState(() {
          _selectedTab = switch (newOrder.status) {
            SalesOrderStatus.confirmed => 2,
            SalesOrderStatus.draft => 1,
            _ => 0,
          };
          _statusFilterKey = null;
          _statusFilterLabel = null;
        });
        await _loadOrders();
      }
    }
  }

  void _showMoreOptions() {
    MoreOptionsSheet.show(
      context,
      sectionLabel: 'SALES ORDER ACTIONS',
      items: [
        MoreOptionsItem(
          icon: Icons.file_download_outlined,
          title: 'Export Sales Orders',
          subtitle: 'Export the current sales order list',
          onTap: () => ToastificationHelper.showInfo(
            context,
            'Export coming soon.',
          ),
        ),
        MoreOptionsItem(
          icon: Icons.refresh_rounded,
          title: 'Refresh',
          subtitle: 'Reload the latest sales orders',
          onTap: () => _refreshKey.currentState?.show(),
        ),
      ],
    );
  }

  void _openFilterSheet() {
    // Build options from the server-provided statuses list if available,
    // otherwise fall back to the local enum values.
    final serverStatuses = _controller.options?.statuses ?? [];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        if (serverStatuses.isNotEmpty) {
          // Use server status options (string-keyed)
          return FilterSheet<String>(
            title: 'Filter',
            showHeaderBorder: true,
            sectionLabel: 'DEFAULT FILTERS',
            // first item is "all_statuses" → treated as null (clear filter)
            options: serverStatuses.map((s) => s.key).toList(),
            selectedValue: _statusFilterKey ?? serverStatuses.first.key,
            labelBuilder: (key) =>
                serverStatuses
                    .firstWhere((s) => s.key == key,
                        orElse: () => serverStatuses.first)
                    .label,
            onSelected: (key) {
              final isAll = key == 'all_statuses' || key == null;
              setState(() {
                _statusFilterKey = isAll ? null : key;
                _statusFilterLabel = isAll
                    ? null
                    : serverStatuses
                        .firstWhere((s) => s.key == key,
                            orElse: () => serverStatuses.first)
                        .label;
                if (!isAll) _selectedTab = 0;
              });
              Navigator.pop(ctx);
              _loadOrders();
            },
            onClose: () => Navigator.pop(ctx),
          );
        }

        // Fallback to local enum-based filter
        return FilterSheet<SalesOrderStatus>(
          title: 'Filter',
          showHeaderBorder: true,
          sectionLabel: 'DEFAULT FILTERS',
          options: const [null, ...SalesOrderStatus.values],
          selectedValue: _statusFilterKey != null
              ? SalesOrderStatus.values.firstWhere(
                  (s) => s.name == _statusFilterKey,
                  orElse: () => SalesOrderStatus.draft,
                )
              : null,
          labelBuilder: (s) => s?.label ?? 'All Statuses',
          onSelected: (status) {
            setState(() {
              _statusFilterKey = status?.name;
              _statusFilterLabel = status?.label;
            });
            Navigator.pop(ctx);
            _loadOrders();
          },
          onClose: () => Navigator.pop(ctx),
        );
      },
    );
  }

  void _openSortSheet() {
    GenericSortSheet.show<SalesOrderSortField>(
      context,
      fields: SalesOrderSortField.values,
      initialField: _sortField,
      initialDirection: _sortDirection,
      labelBuilder: (f) => f.label,
      onApply: (field, direction) {
        setState(() {
          _sortField = field;
          _sortDirection = direction;
        });
        _loadOrders();
      },
      showInfoBanner: true,
    );
  }

  void _openOrderActions(SalesOrderModel order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder: (context) => SalesOrderActionsSheet(
        order: order,
        onStatusChanged: (newStatus) {
          ToastificationHelper.showSuccess(
            context,
            'Status updated to ${newStatus.label}',
          );
          _controller.loadOptions();
          _loadOrders();
        },
        onDelete: () => _deleteOrder(order),
      ),
    );
  }

  void _changeOrderStatus(SalesOrderModel order, SalesOrderStatus newStatus) {
    ToastificationHelper.showSuccess(
      context,
      'Status updated to ${newStatus.label}',
    );
    _controller.loadOptions();
    _loadOrders();
  }

  void _deleteOrder(SalesOrderModel order) {
    ToastificationHelper.showSuccess(context, 'Sales Order deleted');
    _controller.loadOptions();
    _loadOrders();
  }

  void _openOrderDetails(SalesOrderModel order) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => SalesOrderDetailsPage(
          order: order,
          onStatusChanged: (newStatus) => _changeOrderStatus(order, newStatus),
          onDelete: () => _deleteOrder(order),
        ),
      ),
    );
  }

  /// Tab label — appends count badge if available.
  String _tabLabel(int index) {
    final labels = _controller.tabLabels;
    final label = index < labels.length ? labels[index] : ['All', 'Draft', 'Confirmed'][index];
    final key = _tabFilterKeys[index] ?? 'all';
    final count = _controller.counts[key];
    if (count != null) return '$label ($count)';
    return label;
  }

  @override
  Widget build(BuildContext context) {
    final orders = _controller.orders;
    final isLoading = _controller.isLoading;
    final errorMessage = _controller.errorMessage;
    final totalCount = _controller.totalCount;

    return Scaffold(
      backgroundColor: context.colors.background,
      drawer: const DrawerView(currentRoute: 'sales_orders'),
      floatingActionButton: CustomAddButton(onPressed: _addNewSalesOrder),
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshKey,
          color: AppColors.primary,
          backgroundColor: context.colors.card,
          strokeWidth: 2.5,
          onRefresh: () async {
            await _controller.loadOptions();
            await _loadOrders();
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              CustomSliverAppBar(
                title: 'Sales Orders',
                subtitle:
                    '$totalCount sales order${totalCount == 1 ? '' : 's'}',
                leadingType: AppBarLeadingType.menu,
                actions: [
                  AppBarIconButton(
                    icon: _searchOpen
                        ? Icons.close_rounded
                        : Icons.search_rounded,
                    onPressed: () {
                      setState(() {
                        _searchOpen = !_searchOpen;
                        if (!_searchOpen) {
                          _searchController.clear();
                          _loadOrders();
                        }
                      });
                    },
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

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Search Field
                    if (_searchOpen)
                      ListSearchField(
                        controller: _searchController,
                        hintText:
                            'Search by customer, sales order or reference',
                        onChanged: _onSearchChanged,
                      ),

                    // Tab + Filter + Sort bar
                    ListControlBar(
                      tabs: [
                        _tabLabel(0),
                        _tabLabel(1),
                        _tabLabel(2),
                      ],
                      selectedTab: _selectedTab,
                      onTabSelected: (index) {
                        setState(() {
                          _selectedTab = index;
                          _statusFilterKey = null;
                          _statusFilterLabel = null;
                        });
                        _loadOrders();
                      },
                      filterActive: _statusFilterKey != null,
                      onFilterTap: _openFilterSheet,
                      onSortTap: _openSortSheet,
                    ),

                    // Active status filter banner
                    if (_statusFilterKey != null && _statusFilterLabel != null)
                      ActiveFilterBanner(
                        label: 'Status: $_statusFilterLabel',
                        onClear: () {
                          setState(() {
                            _statusFilterKey = null;
                            _statusFilterLabel = null;
                          });
                          _loadOrders();
                        },
                      ),
                  ],
                ),
              ),

              // List body
              if (isLoading)
                const SliverFillRemaining(child: DocumentListSkeleton())
              else if (errorMessage != null)
                SliverFillRemaining(child: _buildError(errorMessage))
              else if (orders.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.shopping_bag_outlined,
                    title: 'No sales orders found',
                    subtitle: 'Tap the + button to create a new sales order.',
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
                        if (index == orders.length) {
                          return _controller.hasMore
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: Dimensions.height20,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }
                        final order = orders[index];
                        return DocumentListTile(
                          leadingIcon: Icons.shopping_bag_outlined,
                          leadingColor: AppColors.primary,
                          primaryText: order.customerName,
                          date: formatDate(order.salesOrderDate),
                          documentNumber: order.salesOrderNumber,
                          statusWidget: StatusChip(
                            color: order.status.color,
                            label: order.status.label,
                          ),
                          trailingBadge: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width10 * 0.7,
                              vertical: Dimensions.height10 * 0.2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceLight,
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius30,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: Dimensions.width10 * 0.6,
                                  height: Dimensions.height10 * 0.6,
                                  decoration: BoxDecoration(
                                    color: order.isInvoiced
                                        ? AppColors.success
                                        : context.colors.textTertiary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: Dimensions.width10 / 3),
                                Text(
                                  order.isInvoiced ? 'Invoiced' : 'Not Invoiced',
                                  style: TextStyle(
                                    fontSize: Dimensions.font16 * 0.6,
                                    color: context.colors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          amount:
                              '${order.currency} ${order.total.toStringAsFixed(2)}',
                          onTap: () => _openOrderDetails(order),
                          onLongPress: () => _openOrderActions(order),
                        );
                      },
                      childCount: orders.length + (_controller.hasMore ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
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
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.9,
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            FilledButton.icon(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
