import 'dart:async';

import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_search_field.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/empty_state_widget.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/drawer/views/custom_drawer.dart';
import 'package:custom_books/features/customers/controllers/customers_list_controller.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:custom_books/features/customers/widgets/customer_page_widgets/customer_card_widget.dart';
import 'package:custom_books/features/customers/widgets/customer_page_widgets/customer_filter_sheet.dart';
import 'package:custom_books/features/customers/widgets/customer_page_widgets/customer_sort_sheet.dart';
import 'package:custom_books/core/widgets/more_options_sheet.dart';
import 'package:custom_books/features/customers/views/add_customer_page.dart';
import 'package:flutter/material.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final CustomersListController _controller = CustomersListController();
  final ScrollController _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  String _selectedFilter = 'All Customers';
  bool _searchOpen = false;

  String _sortField = 'Name';
  bool _sortAsc = true;

  @override
  void initState() {
    super.initState();
    appLog('🎯 CustomersPage initialized', name: 'CustomersPage');
    _controller.addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);
    _controller.loadOptions();
    _loadCustomers();
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

  Future<void> _loadCustomers() async {
    await _controller.loadFirstPage(
      filter: _controller.filterKeyForLabel(_selectedFilter),
      sortBy: _controller.sortKeyForLabel(_sortField),
      sortOrder: _sortAsc ? 'asc' : 'desc',
      search: _searchController.text.trim(),
    );
    if (!mounted) return;
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _loadCustomers();
    });
  }

  bool get _isLoading => _controller.isLoading;

  List<CustomerModel> get _customers => _controller.customers;

  void _showMoreOptions() {
    appLog('⋮ More options tapped', name: 'CustomersPage');
    MoreOptionsSheet.show(
      context,
      sectionLabel: 'CUSTOMER ACTIONS',
      items: [
        MoreOptionsItem(
          icon: Icons.upload_file_outlined,
          title: 'Import Customers',
          subtitle: 'Import customers from a file',
          onTap: () => ToastificationHelper.showInfo(
            context,
            'Importing customers is coming soon.',
          ),
        ),
        MoreOptionsItem(
          icon: Icons.file_download_outlined,
          title: 'Export Customers',
          subtitle: 'Export the current customer list',
          onTap: () => ToastificationHelper.showInfo(
            context,
            'Exporting customers is coming soon.',
          ),
        ),
        MoreOptionsItem(
          icon: Icons.refresh_rounded,
          title: 'Refresh',
          subtitle: 'Reload the latest customers',
          onTap: () {
            _loadCustomers();
            ToastificationHelper.showSuccess(context, 'Customers refreshed.');
          },
        ),
      ],
    );
  }

  void _showSortSheet() {
    appLog('🔀 Opening sort sheet', name: 'CustomersPage');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerSortSheet(
        selectedField: _sortField,
        ascending: _sortAsc,
        fields: _controller.sortFieldLabels,
        onApply: (field, ascending) {
          setState(() {
            _sortField = field;
            _sortAsc = ascending;
          });
          _loadCustomers();
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    appLog('📋 Opening filter bottom sheet', name: 'CustomersPage');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CustomerFilterSheet(
        selectedFilter: _selectedFilter,
        filterOptions: _controller.filterLabels,
        onSelected: (filter) {
          if (filter == _selectedFilter) return;
          appLog('✅ Filter selected: $filter', name: 'CustomersPage');
          setState(() {
            _selectedFilter = filter;
          });
          _loadCustomers();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    appLog('🏗️ Building CustomersPage', name: 'CustomersPage');
    return Scaffold(
      backgroundColor: context.colors.background,
      drawer: const DrawerView(currentRoute: 'customers'),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: context.colors.card,
          strokeWidth: 2.5,
          onRefresh: _loadCustomers,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              CustomSliverAppBar(
                title: 'Customers',
                subtitle: '${_controller.totalCount} customers',
                leadingType: AppBarLeadingType.menu,
                actions: [
                  AppBarIconButton(
                    icon: _searchOpen
                        ? Icons.close_rounded
                        : Icons.search_rounded,
                    color: AppColors.primary,
                    onPressed: () {
                      appLog('🔍 Search tapped', name: 'CustomersPage');
                      setState(() {
                        _searchOpen = !_searchOpen;
                        if (!_searchOpen) {
                          _searchController.clear();
                          _loadCustomers();
                        }
                      });
                    },
                  ),
                  SizedBox(width: Dimensions.width10),
                  AppBarIconButton(
                    icon: Icons.more_vert_rounded,
                    color: context.colors.textSecondary,
                    onPressed: _showMoreOptions,
                  ),
                  SizedBox(width: Dimensions.width20),
                ],
              ),

              if (_searchOpen) SliverToBoxAdapter(child: _buildSearchField()),

              SliverToBoxAdapter(child: _buildFilterSegment()),

              if (_isLoading && _customers.isEmpty)
                const SliverToBoxAdapter(child: CustomerListSkeleton())
              else if (_customers.isEmpty)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: EmptyStateWidget(
                      icon: Icons.people_outline_rounded,
                      title: 'No customers found',
                      subtitle: 'Tap the + button to add your first customer.',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= _customers.length) {
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
                          padding: EdgeInsets.only(bottom: Dimensions.height15),
                          child: CustomerCardWidget(
                            customer: _customers[index],
                          ),
                        );
                      },
                      childCount:
                          _customers.length +
                          (_controller.isLoadingMore ? 1 : 0),
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
          appLog('➕ Add Customer FAB tapped', name: 'CustomersPage');
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const AddCustomerPage()),
          );
          if (created == true) _loadCustomers();
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

  Widget _buildSearchField() {
    return ListSearchField(
      controller: _searchController,
      hintText: 'Search by name or email',
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildFilterSegment() {
    String displayText = _selectedFilter.replaceAll(' Customers', '');

    return Padding(
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
              child: GestureDetector(
                onTap: () {
                  appLog('🔽 Filter dropdown tapped', name: 'CustomersPage');
                  _showFilterBottomSheet();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
                  decoration: BoxDecoration(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayText,
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: Dimensions.width10 / 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: Dimensions.iconSize16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: Dimensions.width10 * 0.8),

            GestureDetector(
              onTap: _showSortSheet,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15,
                  vertical: Dimensions.height10,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(Dimensions.radius30),
                ),
                child: Icon(
                  Icons.sort_rounded,
                  size: Dimensions.iconSize20,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
