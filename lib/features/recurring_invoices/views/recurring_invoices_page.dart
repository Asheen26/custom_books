import 'dart:async';
import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/enums/sort_direction.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/active_filter_banner.dart';
import 'package:custom_books/core/widgets/custom_add_button.dart';
import 'package:custom_books/core/widgets/custom_search_field.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/empty_state_widget.dart';
import 'package:custom_books/core/widgets/filter_sheet.dart';
import 'package:custom_books/core/widgets/generic_sort_sheet.dart';
import 'package:custom_books/core/widgets/list_control_bar.dart';
import 'package:custom_books/core/widgets/more_options_sheet.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/drawer/views/custom_drawer.dart';
import 'package:custom_books/features/recurring_invoices/controllers/recurring_invoices_list_controller.dart';
import 'package:custom_books/features/recurring_invoices/models/recurring_invoice_model.dart';
import 'package:custom_books/features/recurring_invoices/views/add_recurring_invoice_page.dart';
import 'package:custom_books/features/recurring_invoices/views/recurring_invoice_details_page.dart';
import 'package:custom_books/features/recurring_invoices/widgets/recurring_invoice_page_widgets.dart';
import 'package:flutter/material.dart';

class RecurringInvoicesPage extends StatefulWidget {
  const RecurringInvoicesPage({super.key});

  @override
  State<RecurringInvoicesPage> createState() => _RecurringInvoicesPageState();
}

class _RecurringInvoicesPageState extends State<RecurringInvoicesPage> {
  final RecurringInvoicesListController _controller =
      RecurringInvoicesListController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  int _selectedTab = 0; // 0: All, 1: Active, 2: Stopped
  bool _searchOpen = false;
  RecurringInvoiceStatus? _statusFilter;
  RecurringInvoiceSortField _sortField = RecurringInvoiceSortField.createdTime;
  SortDirection _sortDirection = SortDirection.descending;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
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

  /// Derives the API status string from the current tab + filter selection.
  String? get _activeStatusParam {
    // Explicit filter sheet selection takes precedence.
    if (_statusFilter != null) return _statusFilter!.name;
    // Tab shortcuts.
    if (_selectedTab == 1) return RecurringInvoiceStatus.active.name;
    if (_selectedTab == 2) return RecurringInvoiceStatus.stopped.name;
    return null;
  }

  Future<void> _loadFirstPage() async {
    await _controller.loadFirstPage(
      status: _activeStatusParam,
      search: _searchController.text.trim(),
    );
  }

  Future<void> _refresh() => _loadFirstPage();

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _loadFirstPage);
  }

  /// Client-side sort applied on top of the paginated API results.
  List<RecurringInvoiceModel> get _sortedProfiles {
    final list = List<RecurringInvoiceModel>.from(_controller.profiles);
    list.sort((a, b) {
      int result;
      switch (_sortField) {
        case RecurringInvoiceSortField.createdTime:
          result = a.createdAt.compareTo(b.createdAt);
        case RecurringInvoiceSortField.profileName:
          result = a.profileName.toLowerCase().compareTo(
            b.profileName.toLowerCase(),
          );
        case RecurringInvoiceSortField.customerName:
          result = a.customerName.toLowerCase().compareTo(
            b.customerName.toLowerCase(),
          );
        case RecurringInvoiceSortField.amount:
          result = a.amount.compareTo(b.amount);
      }
      return _sortDirection == SortDirection.ascending ? result : -result;
    });
    return list;
  }

  Future<void> _addNewProfile() async {
    final result = await Navigator.push<RecurringInvoiceModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddRecurringInvoicePage()),
    );
    if (result != null && mounted) {
      // Reload from the API so the new profile is shown with its real ID.
      await _loadFirstPage();
      if (mounted) {
        ToastificationHelper.showSuccess(
          context,
          '${result.profileName} created successfully',
        );
      }
    }
  }

  void _showMoreOptions() {
    MoreOptionsSheet.show(
      context,
      sectionLabel: 'RECURRING INVOICE ACTIONS',
      items: [
        MoreOptionsItem(
          icon: Icons.file_download_outlined,
          title: 'Export Profiles',
          subtitle: 'Export the current recurring invoice profiles',
          onTap: () => ToastificationHelper.showSuccess(
            context,
            'Recurring invoice profiles exported',
          ),
        ),
        MoreOptionsItem(
          icon: Icons.refresh_rounded,
          title: 'Refresh',
          subtitle: 'Reload the latest recurring invoice profiles',
          onTap: _refresh,
        ),
      ],
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet<RecurringInvoiceStatus>(
        title: 'Filter',
        options: const [null, ...RecurringInvoiceStatus.values],
        selectedValue: _statusFilter,
        labelBuilder: (status) => status?.label ?? 'All Statuses',
        onSelected: (status) {
          setState(() {
            _statusFilter = status;
            // Clear tab selection when an explicit filter is applied.
            _selectedTab = 0;
          });
          _loadFirstPage();
        },
      ),
    );
  }

  void _openSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GenericSortSheet<RecurringInvoiceSortField>(
        fields: RecurringInvoiceSortField.values,
        initialField: _sortField,
        initialDirection: _sortDirection,
        labelBuilder: (f) => f.label,
        onApply: (field, direction) => setState(() {
          _sortField = field;
          _sortDirection = direction;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = _sortedProfiles;
    final totalCount = _controller.totalCount;

    return Scaffold(
      backgroundColor: context.colors.background,
      drawer: const DrawerView(currentRoute: 'recurring_invoices'),
      floatingActionButton: CustomAddButton(onPressed: _addNewProfile),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          CustomSliverAppBar(
            title: 'Recurring Invoices',
            subtitle: '$totalCount profile${totalCount == 1 ? '' : 's'}',
            leadingType: AppBarLeadingType.menu,
            actions: [
              AppBarIconButton(
                icon: _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                onPressed: () {
                  setState(() {
                    _searchOpen = !_searchOpen;
                    if (!_searchOpen) {
                      _searchController.clear();
                      _loadFirstPage();
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
                if (_searchOpen)
                  ListSearchField(
                    controller: _searchController,
                    hintText: 'Search by profile or customer',
                    onChanged: _onSearchChanged,
                  ),
                ListControlBar(
                  tabs: const ['All', 'Active', 'Stopped'],
                  selectedTab: _selectedTab,
                  onTabSelected: (i) {
                    setState(() {
                      _selectedTab = i;
                      _statusFilter = null;
                    });
                    _loadFirstPage();
                  },
                  filterActive: _statusFilter != null,
                  onFilterTap: _openFilterSheet,
                  onSortTap: _openSortSheet,
                ),
                if (_statusFilter != null)
                  ActiveFilterBanner(
                    label: 'Status: ${_statusFilter!.label}',
                    onClear: () {
                      setState(() => _statusFilter = null);
                      _loadFirstPage();
                    },
                  ),
              ],
            ),
          ),
          if (_controller.isLoading)
            const SliverFillRemaining(
              hasScrollBody: true,
              child: DocumentListSkeleton(),
            )
          else if (_controller.errorMessage != null && profiles.isEmpty)
            SliverFillRemaining(
              child: EmptyStateWidget(
                icon: Icons.error_outline_rounded,
                title: 'Something went wrong',
                subtitle: _controller.errorMessage!,
              ),
            )
          else
            SliverFillRemaining(
              child: profiles.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.autorenew_rounded,
                      title: 'No recurring invoices found',
                      subtitle: 'Tap the + button to create a new profile.',
                    )
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          Dimensions.width20,
                          0,
                          Dimensions.width20,
                          Dimensions.listBottomSpace,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        // +1 for the optional load-more indicator at the bottom.
                        itemCount:
                            profiles.length +
                            (_controller.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == profiles.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                          }
                          return RecurringInvoiceTile(
                            profile: profiles[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecurringInvoiceDetailsPage(
                                      profile: profiles[index],
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
    );
  }
}
