import 'dart:async';

import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/enums/sort_direction.dart';
import 'package:custom_books/core/utils/app_logger.dart';
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
import 'package:custom_books/features/quotes/controllers/quotes_list_controller.dart';
import 'package:custom_books/features/quotes/models/quote_model.dart';
import 'package:custom_books/features/quotes/views/add_quote_page.dart';
import 'package:custom_books/features/quotes/views/quote_details_page.dart';
import 'package:custom_books/features/quotes/widgets/quote_actions_sheet.dart';
import 'package:custom_books/features/quotes/widgets/quote_list_item.dart';
import 'package:flutter/material.dart';

enum QuoteSort {
  createdTime,
  lastModifiedTime,
  date,
  quoteNumber,
  customerName,
}

extension QuoteSortLabel on QuoteSort {
  String get label => switch (this) {
    QuoteSort.createdTime => 'Created Time',
    QuoteSort.lastModifiedTime => 'Last Modified Time',
    QuoteSort.date => 'Date',
    QuoteSort.quoteNumber => 'Quote Number',
    QuoteSort.customerName => 'Customer Name',
  };
}

class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  final QuotesListController _controller = QuotesListController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Timer? _searchDebounce;

  int _selectedTab = 0;
  bool _searchOpen = false;
  QuoteStatus? _statusFilter;
  QuoteSort _sort = QuoteSort.createdTime;
  SortDirection _sortDirection = SortDirection.descending;

  static const _tabStatuses = <int, String?>{0: null, 1: 'draft', 2: 'sent'};

  String? get _activeApiStatus {
    if (_statusFilter != null) return _statusFilter!.name;
    return _tabStatuses[_selectedTab];
  }

  @override
  void initState() {
    super.initState();
    appLog('🎯 QuotesPage initialized', name: 'QuotesPage');
    _controller.addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);
    _loadQuotes();
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

  Future<void> _loadQuotes() async {
    await _controller.loadFirstPage(
      status: _activeApiStatus,
      filter: 'all',
      search: _searchController.text.trim(),
    );
    if (!mounted) return;
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _loadQuotes);
  }

  Future<void> _addQuote() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddQuotePage(quoteSequence: (_controller.totalCount + 1)),
      ),
    );
    // Reload after returning from the add page in case a new quote was saved.
    if (mounted) _loadQuotes();
  }

  void _openDetails(QuoteModel quote) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => QuoteDetailsPage(
          quote: quote,
          onStatusChanged: (newStatus) {
            // Reload the list to reflect the updated status.
            _loadQuotes();
          },
          onDelete: _loadQuotes,
        ),
      ),
    );
  }

  void _openActionsSheet(QuoteModel quote) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => QuoteActionsSheet(
        quote: quote,
        onStatusChanged: (newStatus) {
          appLog(
            '🔄 Quote ${quote.quoteNumber} status changed to $newStatus',
            name: 'QuotesPage',
          );
          _loadQuotes();
        },
        onDelete: _loadQuotes,
      ),
    );
  }

  void _showMoreOptions() {
    MoreOptionsSheet.show(
      context,
      sectionLabel: 'QUOTE ACTIONS',
      items: [
        MoreOptionsItem(
          icon: Icons.file_download_outlined,
          title: 'Export Quotes',
          subtitle: 'Export the current quote list',
          onTap: () =>
              ToastificationHelper.showInfo(context, 'Export coming soon.'),
        ),
        MoreOptionsItem(
          icon: Icons.refresh_rounded,
          title: 'Refresh',
          subtitle: 'Reload the latest quotes',
          onTap: () => _refreshIndicatorKey.currentState?.show(),
        ),
      ],
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => FilterSheet<QuoteStatus>(
        title: 'Filter',
        showHeaderBorder: true,
        sectionLabel: 'DEFAULT FILTERS',
        options: const [null, ...QuoteStatus.values],
        selectedValue: _statusFilter,
        labelBuilder: (status) => status?.label ?? 'All Statuses',
        onSelected: (status) {
          setState(() {
            _statusFilter = status;
            _selectedTab = 0;
          });
          Navigator.pop(sheetContext);
          _loadQuotes();
        },
        onClose: () => Navigator.pop(sheetContext),
      ),
    );
  }

  void _showSortSheet() {
    GenericSortSheet.show<QuoteSort>(
      context,
      fields: QuoteSort.values,
      initialField: _sort,
      initialDirection: _sortDirection,
      labelBuilder: (f) => f.label,
      onApply: (field, direction) {
        setState(() {
          _sort = field;
          _sortDirection = direction;
        });
        // Sort is applied client-side on the already-fetched page.
        // If the API later supports server-side sorting, pass it here.
      },
    );
  }

  List<QuoteModel> get _sortedQuotes {
    final list = List<QuoteModel>.from(_controller.quotes);
    list.sort((a, b) {
      int result;
      switch (_sort) {
        case QuoteSort.createdTime:
          result = a.createdAt.compareTo(b.createdAt);
        case QuoteSort.lastModifiedTime:
          result = a.updatedAt.compareTo(b.updatedAt);
        case QuoteSort.date:
          result = a.quoteDate.compareTo(b.quoteDate);
        case QuoteSort.quoteNumber:
          result = a.quoteNumber.compareTo(b.quoteNumber);
        case QuoteSort.customerName:
          result = a.customerName.toLowerCase().compareTo(
            b.customerName.toLowerCase(),
          );
      }
      return _sortDirection == SortDirection.ascending ? result : -result;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final quotes = _sortedQuotes;

    return Scaffold(
      backgroundColor: context.colors.background,
      drawer: const DrawerView(currentRoute: 'quotes'),
      floatingActionButton: CustomAddButton(onPressed: _addQuote),
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: AppColors.primary,
          backgroundColor: context.colors.card,
          strokeWidth: 2.5,
          onRefresh: _loadQuotes,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              CustomSliverAppBar(
                title: 'Quotes',
                subtitle:
                    '${_controller.totalCount} '
                    'quote${_controller.totalCount == 1 ? '' : 's'}',
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
                          _loadQuotes();
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
                        hintText: 'Search by customer, quote or reference',
                        onChanged: _onSearchChanged,
                      ),
                    ListControlBar(
                      tabs: const ['All', 'Draft', 'Sent'],
                      selectedTab: _selectedTab,
                      onTabSelected: (i) {
                        setState(() {
                          _selectedTab = i;
                          _statusFilter = null;
                        });
                        _loadQuotes();
                      },
                      filterActive: _statusFilter != null,
                      onFilterTap: _showFilterSheet,
                      onSortTap: _showSortSheet,
                    ),
                    if (_statusFilter != null)
                      ActiveFilterBanner(
                        label: 'Status: ${_statusFilter!.label}',
                        onClear: () {
                          setState(() => _statusFilter = null);
                          _loadQuotes();
                        },
                      ),
                  ],
                ),
              ),

              if (_controller.isLoading)
                const SliverFillRemaining(child: DocumentListSkeleton())
              else if (quotes.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.request_quote_rounded,
                    title: 'No quotes found',
                    subtitle: 'Tap the + button to create a new quote.',
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
                        // Pagination load-more trigger at end of list.
                        if (index == quotes.length) {
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
                        final quote = quotes[index];
                        return QuoteListItem(
                          quote: quote,
                          onTap: () => _openDetails(quote),
                          onLongPress: () => _openActionsSheet(quote),
                        );
                      },
                      childCount: quotes.length + (_controller.hasMore ? 1 : 0),
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
