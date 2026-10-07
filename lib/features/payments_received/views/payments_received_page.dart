import 'dart:async';

import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/active_filter_banner.dart';
import 'package:custom_books/core/widgets/custom_add_button.dart';
import 'package:custom_books/core/widgets/custom_search_field.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/document_list_tile.dart';
import 'package:custom_books/core/widgets/empty_state_widget.dart';
import 'package:custom_books/core/widgets/list_control_bar.dart';
import 'package:custom_books/core/widgets/more_options_sheet.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/status_chip.dart';
import 'package:custom_books/features/drawer/views/custom_drawer.dart';
import 'package:custom_books/features/payments_received/controllers/payments_received_list_controller.dart';
import 'package:custom_books/features/payments_received/models/payment_received_model.dart';
import 'package:custom_books/features/payments_received/models/payments_received_options_model.dart';
import 'package:custom_books/features/payments_received/views/add_payment_received_page.dart';
import 'package:custom_books/features/payments_received/views/payment_received_details_page.dart';
import 'package:flutter/material.dart';

class PaymentsReceivedPage extends StatefulWidget {
  const PaymentsReceivedPage({super.key});

  @override
  State<PaymentsReceivedPage> createState() => _PaymentsReceivedPageState();
}

class _PaymentsReceivedPageState extends State<PaymentsReceivedPage> {
  final PaymentsReceivedListController _ctrl = PaymentsReceivedListController();
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // ── UI state ──────────────────────────────────────────────────────────────
  int _selectedTabIndex = 0;
  bool _searchOpen = false;

  // Selected mode / sort labels (labels are what the UI stores; keys are
  // looked up via the controller when calling the API).
  String? _selectedModeLabel; // null = 'All Modes'
  String _sortLabel = 'Created Time';
  bool _sortAsc = false;

  // ── lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_refresh);
    _scroll.addListener(_onScroll);
    _ctrl.loadOptions();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _ctrl.removeListener(_refresh);
    _ctrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      _ctrl.loadNextPage();
    }
  }

  // ── data loading ──────────────────────────────────────────────────────────

  Future<void> _load() => _ctrl.loadFirstPage(
    search: _searchController.text.trim(),
    sortBy: _ctrl.sortKeyForLabel(_sortLabel),
    sortOrder: _sortAsc ? 'asc' : 'desc',
    tab: _ctrl.tabKeyForIndex(_selectedTabIndex),
    mode: _selectedModeLabel != null
        ? _ctrl.modeKeyForLabel(_selectedModeLabel!)
        : null,
  );

  void _onSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  // ── actions ───────────────────────────────────────────────────────────────

  Future<void> _addNewPayment() async {
    final result = await Navigator.push<PaymentReceivedModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddPaymentReceivedPage()),
    );
    if (result != null && mounted) {
      _ctrl.prependPayment(result);
      ToastificationHelper.showSuccess(
        context,
        '${result.paymentNumber} created successfully',
      );
    }
  }

  void _showMoreOptions() {
    MoreOptionsSheet.show(
      context,
      sectionLabel: 'PAYMENT ACTIONS',
      items: [
        MoreOptionsItem(
          icon: Icons.file_download_outlined,
          title: 'Export Payments',
          subtitle: 'Export as CSV or JSON',
          onTap: _showExportFormatPicker,
        ),
        MoreOptionsItem(
          icon: Icons.receipt_outlined,
          title: 'Generate Statement',
          subtitle: 'Generate a payment receipt statement',
          onTap: () => ToastificationHelper.showInfo(
            context,
            'Generate statement is coming soon.',
          ),
        ),
        MoreOptionsItem(
          icon: Icons.refresh_rounded,
          title: 'Refresh',
          subtitle: 'Reload the latest payments',
          onTap: _load,
        ),
      ],
    );
  }

  Future<void> _showExportFormatPicker() async {
    final format = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.colors.card,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(Dimensions.width15),
              child: Text(
                'Export Format',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 1.1,
                  fontWeight: FontWeight.w700,
                  color: ctx.colors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.table_chart_outlined,
                color: ctx.colors.textSecondary,
              ),
              title: Text(
                'CSV',
                style: TextStyle(
                  color: ctx.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('Spreadsheet-compatible format'),
              onTap: () => Navigator.pop(ctx, 'csv'),
            ),
            ListTile(
              leading: Icon(
                Icons.data_object_outlined,
                color: ctx.colors.textSecondary,
              ),
              title: Text(
                'JSON',
                style: TextStyle(
                  color: ctx.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('Structured data format'),
              onTap: () => Navigator.pop(ctx, 'json'),
            ),
            SizedBox(height: Dimensions.height10),
          ],
        ),
      ),
    );

    if (format == null || !mounted) return;
    ToastificationHelper.showInfo(
      context,
      'Exporting payments as ${format.toUpperCase()}…',
    );
    final error = await _ctrl.exportPayments(format: format);
    if (!mounted) return;
    if (error == null) {
      ToastificationHelper.showSuccess(
        context,
        'Payments exported successfully.',
      );
    } else {
      ToastificationHelper.showError(context, error);
    }
  }

  // ── filter / sort sheets ──────────────────────────────────────────────────

  void _openFilterSheet() {
    final modes = _ctrl.modeOptions;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModeFilterSheet(
        options: modes,
        selectedLabel: _selectedModeLabel,
        onSelected: (label) {
          setState(() => _selectedModeLabel = label);
          _load();
        },
      ),
    );
  }

  void _openSortSheet() {
    final fields = _ctrl.sortFieldOptions;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        options: fields,
        selectedLabel: _sortLabel,
        ascending: _sortAsc,
        onApply: (label, asc) {
          setState(() {
            _sortLabel = label;
            _sortAsc = asc;
          });
          _load();
        },
      ),
    );
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  bool get _filterActive => _selectedModeLabel != null;

  String get _activeModeLabel =>
      _selectedModeLabel ?? _ctrl.modeOptions.firstOrNull?.label ?? 'All Modes';

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final payments = _ctrl.payments;
    final totalCount = _ctrl.totalCount;
    final tabLabels = _ctrl.tabLabels;

    return Scaffold(
      backgroundColor: context.colors.background,
      drawer: const DrawerView(currentRoute: 'payments_received'),
      floatingActionButton: CustomAddButton(onPressed: _addNewPayment),
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, _) => [
          CustomSliverAppBar(
            title: 'Payments Received',
            subtitle: '$totalCount payment${totalCount == 1 ? '' : 's'}',
            leadingType: AppBarLeadingType.menu,
            actions: [
              AppBarIconButton(
                icon: _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                onPressed: () => setState(() {
                  _searchOpen = !_searchOpen;
                  if (!_searchOpen) {
                    _searchController.clear();
                    _load();
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
        ],
        body: Column(
          children: [
            // ── search bar ────────────────────────────────────────────────
            if (_searchOpen)
              ListSearchField(
                controller: _searchController,
                hintText: 'Search by customer, payment or reference',
                onChanged: _onSearch,
              ),

            // ── tab / filter / sort bar ───────────────────────────────────
            ListControlBar(
              tabs: tabLabels.isNotEmpty ? tabLabels : const ['All'],
              selectedTab: _selectedTabIndex,
              onTabSelected: (i) {
                setState(() {
                  _selectedTabIndex = i;
                  _selectedModeLabel = null;
                });
                _load();
              },
              filterActive: _filterActive,
              onFilterTap: _openFilterSheet,
              onSortTap: _openSortSheet,
            ),

            // ── active mode filter banner ─────────────────────────────────
            if (_filterActive)
              ActiveFilterBanner(
                label: 'Mode: $_activeModeLabel',
                onClear: () {
                  setState(() => _selectedModeLabel = null);
                  _load();
                },
              ),

            // ── list ──────────────────────────────────────────────────────
            Expanded(
              child: _ctrl.isLoading && payments.isEmpty
                  ? const DocumentListSkeleton()
                  : _ctrl.errorMessage != null && payments.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(Dimensions.width20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: Dimensions.iconSize24 * 2,
                              color: context.colors.textTertiary,
                            ),
                            SizedBox(height: Dimensions.height20),
                            Text(
                              _ctrl.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                              ),
                            ),
                            SizedBox(height: Dimensions.height20),
                            TextButton.icon(
                              onPressed: _load,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : payments.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.payments_outlined,
                      title: 'No payments found',
                      subtitle: 'Tap the + button to record a new payment.',
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        controller: _scroll,
                        padding: EdgeInsets.fromLTRB(
                          Dimensions.width20,
                          0,
                          Dimensions.width20,
                          Dimensions.listBottomSpace,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount:
                            payments.length + (_ctrl.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= payments.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              ),
                            );
                          }
                          final payment = payments[index];
                          return DocumentListTile(
                            leadingIcon: Icons.payments_outlined,
                            leadingColor: AppColors.success,
                            primaryText: payment.customerName,
                            date: formatDate(payment.paymentDate),
                            documentNumber: payment.paymentNumber,
                            statusWidget: StatusChip(
                              color: AppColors.primaryLight,
                              label: payment.mode.label,
                            ),
                            amount: '₹${payment.amount.toStringAsFixed(2)}',
                            amountColor: AppColors.success,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentReceivedDetailsPage(
                                  payment: payment,
                                  actions: _ctrl.actions,
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
}

// ── Mode filter sheet ─────────────────────────────────────────────────────────

class _ModeFilterSheet extends StatelessWidget {
  final List<PaymentReceivedOption> options;
  final String? selectedLabel;
  final void Function(String? label) onSelected;

  const _ModeFilterSheet({
    required this.options,
    required this.selectedLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius15 * 1.33),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: Dimensions.height10 / 2),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Dimensions.width15),
              child: Text(
                'Filter by Mode',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 1.1,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: options.map((opt) {
                  // The first option (all_modes) clears the filter.
                  final bool isAllModes =
                      opt.key == 'all_modes' || opt.key.startsWith('all');
                  final bool isSelected = isAllModes
                      ? selectedLabel == null
                      : selectedLabel == opt.label;
                  return ListTile(
                    title: Text(
                      opt.label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : context.colors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(isAllModes ? null : opt.label);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sort sheet ────────────────────────────────────────────────────────────────

class _SortSheet extends StatefulWidget {
  final List<PaymentReceivedOption> options;
  final String selectedLabel;
  final bool ascending;
  final void Function(String label, bool ascending) onApply;

  const _SortSheet({
    required this.options,
    required this.selectedLabel,
    required this.ascending,
    required this.onApply,
  });

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late String _label;
  late bool _asc;

  @override
  void initState() {
    super.initState();
    _label = widget.selectedLabel;
    _asc = widget.ascending;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius15 * 1.33),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: Dimensions.height10 / 2),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Dimensions.width15),
              child: Text(
                'Sort By',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 1.1,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            // ── sort field options ──────────────────────────────────────
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.options.map((opt) {
                  final bool isSelected = _label == opt.label;
                  return ListTile(
                    title: Text(
                      opt.label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : context.colors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, color: AppColors.primary)
                        : null,
                    onTap: () => setState(() => _label = opt.label),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),
            // ── direction toggle ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _DirectionButton(
                      label: 'Ascending',
                      icon: Icons.arrow_upward_rounded,
                      selected: _asc,
                      onTap: () => setState(() => _asc = true),
                    ),
                  ),
                  SizedBox(width: Dimensions.width10),
                  Expanded(
                    child: _DirectionButton(
                      label: 'Descending',
                      icon: Icons.arrow_downward_rounded,
                      selected: !_asc,
                      onTap: () => setState(() => _asc = false),
                    ),
                  ),
                ],
              ),
            ),
            // ── apply button ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                Dimensions.width20,
                0,
                Dimensions.width20,
                Dimensions.height20,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onApply(_label, _asc);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radius15),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontWeight: FontWeight.w700),
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

class _DirectionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DirectionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : context.colors.surfaceLight,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
            color: selected ? AppColors.primary : context.colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: Dimensions.iconSize16,
              color: selected
                  ? AppColors.primary
                  : context.colors.textSecondary,
            ),
            SizedBox(width: Dimensions.width10 / 2),
            Text(
              label,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.78,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                color: selected
                    ? AppColors.primary
                    : context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
