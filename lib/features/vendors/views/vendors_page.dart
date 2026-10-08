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
import 'package:custom_books/core/enums/sort_direction.dart';
import 'package:custom_books/core/widgets/filter_sheet.dart';
import 'package:custom_books/core/widgets/generic_sort_sheet.dart';
import 'package:custom_books/core/widgets/list_control_bar.dart';
import 'package:custom_books/core/widgets/more_options_sheet.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/drawer/views/custom_drawer.dart';
import 'package:custom_books/features/vendors/controllers/vendors_list_controller.dart';
import 'package:custom_books/features/vendors/models/vendor_model.dart';
import 'package:custom_books/features/vendors/models/vendor_options_model.dart';
import 'package:custom_books/features/vendors/views/add_vendor_page.dart';
import 'package:custom_books/features/vendors/views/vendor_details_page.dart';
import 'package:flutter/material.dart';

class VendorsPage extends StatefulWidget {
  const VendorsPage({super.key});

  @override
  State<VendorsPage> createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPage> {
  final VendorsListController _controller = VendorsListController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  /// Index into _controller.tabs (0 = All, 1 = Active, 2 = Inactive).
  int _selectedTabIndex = 0;

  bool _searchOpen = false;

  /// Currently selected status filter key (e.g. 'active', 'inactive').
  /// null means no extra filter beyond the selected tab.
  String? _statusFilterKey;

  /// Currently selected sort field option (null until options load).
  VendorOption? _sortField;

  /// Currently selected sort direction.
  SortDirection _sortDirection = SortDirection.descending;

  @override
  void initState() {
    super.initState();
    appLog('🎯 VendorsPage initialized', name: 'VendorsPage');
    _controller.addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);
    // Load options first; the callback will pick up default sort once ready.
    _controller.loadOptions().then((_) {
      if (!mounted) return;
      // Apply server-provided default sort field if not yet set.
      if (_sortField == null) {
        final fields = _controller.sortFields;
        final defaultKey = _controller.defaultSortBy;
        _sortField =
            fields.where((f) => f.key == defaultKey).firstOrNull ??
            (fields.isNotEmpty ? fields.first : null);
      }
      if (_controller.defaultSortOrder == 'asc') {
        _sortDirection = SortDirection.ascending;
      }
      _loadVendors();
    });
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

  /// Derives the `filter=` tab key from the selected tab index.
  String? _tabFilterKey() {
    final tabs = _controller.tabs;
    if (_selectedTabIndex <= 0 || _selectedTabIndex >= tabs.length) return null;
    final key = tabs[_selectedTabIndex].key;
    // 'all' tab sends no filter param.
    return key == 'all' ? null : key;
  }

  Future<void> _loadVendors() async {
    await _controller.loadFirstPage(
      search: _searchController.text.trim(),
      filter: _tabFilterKey(),
      status: _statusFilterKey,
      sortBy: _sortField?.key ?? _controller.defaultSortBy,
      sortOrder: _sortDirection == SortDirection.ascending ? 'asc' : 'desc',
    );
    if (!mounted) return;
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _loadVendors);
  }

  Future<void> _addNewVendor() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddVendorPage()),
    );
    if (result == true && mounted) {
      await _controller.refresh();
    }
  }

  Future<void> _exportVendors() async {
    ToastificationHelper.showInfo(context, 'Exporting vendors…');
    final error = await _controller.exportVendors();
    if (!mounted) return;
    if (error == null) {
      ToastificationHelper.showSuccess(
        context,
        'Vendors exported successfully.',
      );
    } else {
      ToastificationHelper.showError(context, error);
    }
  }

  void _showMoreOptions() {
    MoreOptionsSheet.show(
      context,
      sectionLabel: 'VENDOR ACTIONS',
      items: [
        MoreOptionsItem(
          icon: Icons.upload_file_outlined,
          title: 'Import Vendors',
          subtitle: 'Import vendors from a file',
          onTap: () => ToastificationHelper.showInfo(
            context,
            'Importing vendors is coming soon.',
          ),
        ),
        MoreOptionsItem(
          icon: Icons.file_download_outlined,
          title: 'Export Vendors',
          subtitle: 'Export the current vendor list',
          onTap: _exportVendors,
        ),
        MoreOptionsItem(
          icon: Icons.refresh_rounded,
          title: 'Refresh',
          subtitle: 'Reload the latest vendors',
          onTap: _loadVendors,
        ),
      ],
    );
  }

  void _openFilterSheet() {
    final statuses = _controller.statuses;
    // Build option list: null represents "no extra filter" (All Vendors entry).
    // The first entry from the server has key 'all_vendors' — treat it as null.
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet<VendorOption?>(
        title: 'Filter by Status',
        compact: true,
        style: FilterOptionStyle.card,
        options: [null, ...statuses.skip(1)],
        selectedValue: statuses
            .skip(1)
            .where((o) => o.key == _statusFilterKey)
            .firstOrNull,
        labelBuilder: (option) => option == null
            ? (statuses.isNotEmpty ? statuses.first.label : 'All Vendors')
            : option.label,
        onSelected: (option) {
          setState(() => _statusFilterKey = option?.key);
          _loadVendors();
        },
      ),
    );
  }

  void _openSortSheet() {
    final fields = _controller.sortFields;
    if (fields.isEmpty) return;

    final currentField = _sortField ?? fields.first;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GenericSortSheet<VendorOption>(
        fields: fields,
        initialField: currentField,
        initialDirection: _sortDirection,
        labelBuilder: (f) => f.label,
        onApply: (field, direction) {
          setState(() {
            _sortField = field;
            _sortDirection = direction;
          });
          _loadVendors();
        },
        compact: true,
        buttonLabel: 'Apply',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendors = _controller.vendors;
    final tabs = _controller.tabs;

    // Build tab labels; append count when available.
    final tabLabels = tabs.map((t) {
      final count = _controller.countForTab(t.key);
      return count > 0 ? '${t.label} ($count)' : t.label;
    }).toList();

    // Label for the active status filter banner.
    String? filterBannerLabel;
    if (_statusFilterKey != null) {
      final match = _controller.statuses
          .where((s) => s.key == _statusFilterKey)
          .firstOrNull;
      filterBannerLabel = match != null
          ? 'Status: ${match.label}'
          : 'Status: $_statusFilterKey';
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      drawer: const DrawerView(currentRoute: 'vendors'),
      floatingActionButton: CustomAddButton(onPressed: _addNewVendor),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          CustomSliverAppBar(
            title: 'Vendors',
            subtitle:
                '${_controller.totalCount} vendor${_controller.totalCount == 1 ? '' : 's'}',
            leadingType: AppBarLeadingType.menu,
            actions: [
              AppBarIconButton(
                icon: _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                onPressed: () => setState(() {
                  _searchOpen = !_searchOpen;
                  if (!_searchOpen) {
                    _searchController.clear();
                    _loadVendors();
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
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (_searchOpen)
                  ListSearchField(
                    controller: _searchController,
                    hintText: 'Search by name, company or email',
                    onChanged: _onSearchChanged,
                  ),
                ListControlBar(
                  tabs: tabLabels.isEmpty
                      ? const ['All', 'Active', 'Inactive']
                      : tabLabels,
                  selectedTab: _selectedTabIndex,
                  onTabSelected: (i) {
                    setState(() {
                      _selectedTabIndex = i;
                      _statusFilterKey = null;
                    });
                    _loadVendors();
                  },
                  filterActive: _statusFilterKey != null,
                  onFilterTap: _openFilterSheet,
                  onSortTap: _openSortSheet,
                ),
                if (filterBannerLabel != null)
                  ActiveFilterBanner(
                    label: filterBannerLabel,
                    onClear: () {
                      setState(() => _statusFilterKey = null);
                      _loadVendors();
                    },
                  ),
              ],
            ),
          ),
          if (_controller.isLoading)
            const SliverFillRemaining(child: DocumentListSkeleton())
          else if (vendors.isEmpty)
            const SliverFillRemaining(
              child: EmptyStateWidget(
                icon: Icons.store_outlined,
                title: 'No vendors found',
                subtitle: 'Tap the + button to add a new vendor.',
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == vendors.length) {
                    return _controller.isLoadingMore
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height10,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : const SizedBox.shrink();
                  }
                  return _vendorTile(vendors[index]);
                }, childCount: vendors.length + 1),
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _vendorTile(VendorModel vendor) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VendorDetailsPage(vendor: vendor)),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: Dimensions.height10),
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Dimensions.height45 * 0.78,
              height: Dimensions.height45 * 0.78,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                _initials(vendor.displayName),
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.85,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: Dimensions.width15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.displayName,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.95,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: Dimensions.height10 / 2),
                  Row(
                    children: [
                      Icon(
                        Icons.business_rounded,
                        size: Dimensions.iconSize16 * 0.875,
                        color: context.colors.textTertiary,
                      ),
                      SizedBox(width: Dimensions.width10 / 2),
                      Flexible(
                        child: Text(
                          vendor.companyName.isEmpty
                              ? vendor.email
                              : vendor.companyName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Dimensions.font16 * 0.7,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10 / 2),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: Dimensions.iconSize16 * 0.875,
                        color: context.colors.textTertiary,
                      ),
                      SizedBox(width: Dimensions.width10 / 2),
                      Flexible(
                        child: Text(
                          vendor.phone.isEmpty ? vendor.email : vendor.phone,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Dimensions.font16 * 0.7,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: Dimensions.width10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Payables',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.6,
                    color: context.colors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: Dimensions.height10 / 3),
                Text(
                  '₹${vendor.payables.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
