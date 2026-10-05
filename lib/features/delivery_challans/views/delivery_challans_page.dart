import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/active_filter_banner.dart';
import 'package:custom_books/core/widgets/custom_search_field.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/empty_state_widget.dart';
import 'package:custom_books/core/widgets/filter_sheet.dart';
import 'package:custom_books/core/widgets/list_control_bar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/delivery_challans/controllers/delivery_challans_list_controller.dart';
import 'package:custom_books/features/delivery_challans/models/delivery_challan_model.dart';
import 'package:custom_books/features/delivery_challans/views/add_delivery_challan_page.dart';
import 'package:custom_books/features/delivery_challans/widgets/delivery_challan_card.dart';
import 'package:custom_books/features/delivery_challans/views/delivery_challan_details_page.dart';
import 'package:custom_books/features/delivery_challans/widgets/delivery_challan_sort_sheet.dart';
import 'package:custom_books/core/widgets/more_options_sheet.dart';
import 'package:custom_books/features/drawer/views/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:custom_books/core/enums/sort_direction.dart';

class DeliveryChallansPage extends StatefulWidget {
  const DeliveryChallansPage({super.key});

  @override
  State<DeliveryChallansPage> createState() => _DeliveryChallansPageState();
}

class _DeliveryChallansPageState extends State<DeliveryChallansPage> {
  final DeliveryChallansListController _controller =
      DeliveryChallansListController();
  final TextEditingController _searchController = TextEditingController();

  int _selectedTab = 0; // 0: All, 1: Draft, 2: Delivered
  bool _searchOpen = false;
  DeliveryChallanStatus? _statusFilter;
  DeliveryChallanSortField _sortField = DeliveryChallanSortField.createdTime;
  SortDirection _sortDirection = SortDirection.descending;

  static const Map<DeliveryChallanSortField, String> _sortApiValues = {
    DeliveryChallanSortField.createdTime: 'created_time',
    DeliveryChallanSortField.date: 'date',
    DeliveryChallanSortField.challanNumber: 'challan_number',
    DeliveryChallanSortField.customerName: 'customer_name',
    DeliveryChallanSortField.amount: 'total_amount',
  };

  static const List<String> _tabStatusValues = ['all', 'draft', 'delivered'];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _loadChallans();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadChallans() async {
    final statusParam = _statusFilter != null
        ? _statusFilter!.name
        : _tabStatusValues[_selectedTab];

    await _controller.load(
      status: statusParam,
      sortBy: _sortApiValues[_sortField],
      sortOrder: _sortDirection == SortDirection.ascending ? 'asc' : 'desc',
    );

    if (!mounted) return;
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  List<DeliveryChallanModel> get _visibleChallans {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _controller.challans.toList();
    return _controller.challans.where((c) {
      return c.customerName.toLowerCase().contains(query) ||
          c.challanNumber.toLowerCase().contains(query) ||
          c.referenceNumber.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _addNewChallan() async {
    final result = await Navigator.push<DeliveryChallanModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddDeliveryChallanPage()),
    );
    if (result == null || !mounted) return;
    await _loadChallans();
    if (!mounted) return;
    ToastificationHelper.showSuccess(
      context,
      '${result.challanNumber} created successfully',
    );
  }

  void _showMoreOptions() {
    MoreOptionsSheet.show(
      context,
      sectionLabel: 'DELIVERY CHALLAN ACTIONS',
      items: [
        MoreOptionsItem(
          icon: Icons.file_download_outlined,
          title: 'Export Delivery Challans',
          subtitle: 'Export the current delivery challan list',
          onTap: () => ToastificationHelper.showSuccess(
            context,
            'Delivery challans exported',
          ),
        ),
        MoreOptionsItem(
          icon: Icons.print_outlined,
          title: 'Print',
          subtitle: 'Print delivery challan documents',
          onTap: () => ToastificationHelper.showInfo(
            context,
            'Printing delivery challans is coming soon.',
          ),
        ),
        MoreOptionsItem(
          icon: Icons.refresh_rounded,
          title: 'Refresh',
          subtitle: 'Reload the latest delivery challans',
          onTap: () {
            _loadChallans();
            ToastificationHelper.showSuccess(
              context,
              'Delivery challans refreshed.',
            );
          },
        ),
      ],
    );
  }

  void _openFilterSheet() async {
    final result = await showModalBottomSheet<DeliveryChallanStatus?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet<DeliveryChallanStatus>(
        title: 'Filter',
        options: const [null, ...DeliveryChallanStatus.values],
        selectedValue: _statusFilter,
        labelBuilder: (status) => status?.label ?? 'All Statuses',
        onSelected: (status) => Navigator.pop(context, status),
        onClose: () => Navigator.pop(context),
      ),
    );

    if (result != null || _statusFilter != null) {
      setState(() => _statusFilter = result);
      _loadChallans();
    }
  }

  void _openSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeliveryChallanSortSheet(
        selectedField: _sortField,
        selectedDirection: _sortDirection,
        onApply: (field, direction) {
          setState(() {
            _sortField = field;
            _sortDirection = direction;
          });
          _loadChallans();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleList = _visibleChallans;
    final totalCount = _controller.challans.length;

    return Scaffold(
      backgroundColor: context.colors.background,
      drawer: const DrawerView(currentRoute: 'delivery_challans'),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: Dimensions.radius15 * 1.07,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _addNewChallan,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
          ),
          child: const Icon(Icons.add_rounded),
        ),
      ),
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, _) => [
          CustomSliverAppBar(
            title: 'Delivery Challans',
            subtitle:
                '$totalCount delivery challan${totalCount == 1 ? '' : 's'}',
            leadingType: AppBarLeadingType.menu,
            actions: [
              AppBarIconButton(
                icon: _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                onPressed: () => setState(() {
                  _searchOpen = !_searchOpen;
                  if (!_searchOpen) _searchController.clear();
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
        ],
        body: Column(
          children: [
            if (_searchOpen)
              ListSearchField(
                controller: _searchController,
                hintText: 'Search by customer, challan or reference',
                onChanged: (_) => setState(() {}),
              ),
            ListControlBar(
              tabs: const ['All', 'Draft', 'Delivered'],
              selectedTab: _selectedTab,
              onTabSelected: (index) {
                setState(() {
                  _selectedTab = index;
                  _statusFilter = null;
                });
                _loadChallans();
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
                  _loadChallans();
                },
              ),
            Expanded(
              child: _controller.isLoading
                  ? const DocumentListSkeleton()
                  : visibleList.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.local_shipping_outlined,
                      title: 'No delivery challans found',
                      subtitle:
                          'Tap the + button to create a new delivery challan.',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadChallans,
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
                        itemCount: visibleList.length,
                        itemBuilder: (context, index) => InkWell(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius15,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DeliveryChallanDetailsPage(
                                challan: visibleList[index],
                              ),
                            ),
                          ),
                          child: DeliveryChallanCard(
                            challan: visibleList[index],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
