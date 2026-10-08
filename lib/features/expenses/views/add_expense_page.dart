import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/models/attachment_file.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/attachment_picker.dart';
import 'package:custom_books/core/widgets/bottom_sheet_drag_handle.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/expenses/models/expense_model.dart';
import 'package:flutter/material.dart';

class AddExpensePage extends StatefulWidget {
  final ExpenseModel? existing;

  const AddExpensePage({super.key, this.existing});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage>
    with UnsavedChangesMixin {
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  final _invoiceController = TextEditingController();
  final _notesController = TextEditingController();

  String? _location;
  DateTime _expenseDate = DateTime.now();
  String? _expenseAccount;
  String? _paidThrough;
  bool _itemize = false;
  String? _vendorName;
  String? _customer;
  List<String> _reportingTags = [];
  List<AttachmentFile> _receipts = [];
  bool _isLoading = true;

  static const List<String> _locations = [
    'warehouse1',
    'warehouse2',
    'office1',
    'office2',
  ];

  static const List<String> _expenseAccounts = [
    'Advertising',
    'Automobile Expense',
    'Bad Debt',
    'Bank Fees',
    'Consultant Expense',
    'Travel Expense',
    'Utilities',
    'Other Expenses',
  ];

  static const List<String> _paymentAccounts = [
    'Cash',
    'Petty Cash',
    'HDFC Bank',
    'ICICI Bank',
    'Credit Card',
  ];

  static const List<String> _vendors = [
    'Global Supplies',
    'Metro Traders',
    'Al Noor Co',
    'Prime Distributors',
  ];

  static const List<String> _customers = [
    'ABC Corporation',
    'XYZ Ltd',
    'Tech Solutions',
    'Global Enterprises',
  ];

  static const List<String> _availableTags = [
    'Project A',
    'Project B',
    'Department - Sales',
    'Department - Marketing',
    'Region - North',
    'Region - South',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.existing != null) {
      final e = widget.existing!;
      _expenseAccount = e.category.isEmpty ? null : e.category;
      _vendorName = e.vendorName.isEmpty ? null : e.vendorName;
      _expenseDate = e.expenseDate;
      _referenceController.text = e.referenceNumber;
      _amountController.text = e.amount.toStringAsFixed(2);
    }
    _referenceController.addListener(markDirty);
    _amountController.addListener(markDirty);
    _invoiceController.addListener(markDirty);
    _notesController.addListener(markDirty);
  }

  @override
  void dispose() {
    _referenceController.removeListener(markDirty);
    _amountController.removeListener(markDirty);
    _invoiceController.removeListener(markDirty);
    _notesController.removeListener(markDirty);
    _referenceController.dispose();
    _amountController.dispose();
    _invoiceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _expenseDate = picked);
      markDirty();
    }
  }

  Future<void> _selectLocation() async {
    final selected = await _selectFromSheet(
      'Select Location',
      _locations,
      _location,
    );
    if (selected != null) {
      setState(() => _location = selected);
      markDirty();
    }
  }

  Future<void> _selectExpenseAccount() async {
    final selected = await _selectFromSheet(
      'Select Expense Account',
      _expenseAccounts,
      _expenseAccount,
    );
    if (selected != null) {
      setState(() => _expenseAccount = selected);
      markDirty();
    }
  }

  Future<void> _selectPaidThrough() async {
    final selected = await _selectFromSheet(
      'Select Account',
      _paymentAccounts,
      _paidThrough,
    );
    if (selected != null) {
      setState(() => _paidThrough = selected);
      markDirty();
    }
  }

  Future<void> _selectVendor() async {
    final selected = await _selectFromSheet(
      'Select Vendor',
      _vendors,
      _vendorName,
    );
    if (selected != null) {
      setState(() => _vendorName = selected);
      markDirty();
    }
  }

  Future<void> _selectCustomer() async {
    final selected = await _selectFromSheet(
      'Select Customer',
      _customers,
      _customer,
    );
    if (selected != null) {
      setState(() => _customer = selected);
      markDirty();
    }
  }

  Future<void> _selectReportingTags() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.colors.card,
      builder: (context) => _ReportingTagsSheet(
        options: _availableTags,
        selected: List.from(_reportingTags),
      ),
    );
    if (result != null) {
      setState(() => _reportingTags = result);
      markDirty();
    }
  }

  Future<String?> _selectFromSheet(
    String title,
    List<String> options,
    String? current,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.colors.card,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(Dimensions.width15),
              child: Text(
                title,
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
                children: options
                    .map(
                      (option) => ListTile(
                        title: Text(
                          option,
                          style: TextStyle(
                            color: option == current
                                ? AppColors.primary
                                : context.colors.textPrimary,
                            fontWeight: option == current
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: option == current
                            ? Icon(
                                Icons.check_rounded,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, option),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveExpense({ExpenseStatus status = ExpenseStatus.unbilled}) {
    if (_expenseAccount == null || _expenseAccount!.trim().isEmpty) {
      ToastificationHelper.showWarning(
        context,
        'Please select an Expense Account.',
      );
      return;
    }
    if (_amountController.text.trim().isEmpty) {
      ToastificationHelper.showWarning(context, 'Please enter an Amount.');
      return;
    }

    final newExpense = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _expenseAccount!.trim(),
      vendorName: _vendorName ?? '',
      expenseDate: _expenseDate,
      referenceNumber: _referenceController.text.trim(),
      status: status,
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    markClean();
    Navigator.pop(context, newExpense);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: _isLoading
              ? const FormPageSkeleton()
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    CustomSliverAppBar(
                      title: widget.existing == null
                          ? 'New Expense'
                          : 'Edit Expense',
                      leadingType: AppBarLeadingType.back,
                      onLeadingPressed: () =>
                          onPopInvokedWithResult(false, null),
                      actions: [
                        AppBarElevatedButton(
                          label: 'SAVE',
                          onPressed: () =>
                              _saveExpense(status: ExpenseStatus.unbilled),
                        ),
                        SizedBox(width: Dimensions.width10),
                        AppBarIconButton(
                          icon: Icons.more_vert_rounded,
                          color: AppColors.accent,
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => Container(
                                decoration: BoxDecoration(
                                  color: context.colors.card,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                      Dimensions.radius20 * 1.2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const BottomSheetDragHandle(),
                                    ListTile(
                                      leading: Icon(
                                        Icons.receipt_rounded,
                                        color: AppColors.primary,
                                      ),
                                      title: Text(
                                        'Save as Billed',
                                        style: TextStyle(
                                          fontSize: Dimensions.font16 * 0.9,
                                          fontWeight: FontWeight.w600,
                                          color: context.colors.textPrimary,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _saveExpense(
                                          status: ExpenseStatus.billed,
                                        );
                                      },
                                    ),
                                    SizedBox(height: Dimensions.height20),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: Dimensions.width20),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(Dimensions.width15),
                        child: Column(
                          children: [
                            // ── Card 1: Location / Date+Attach / Account / Paid Through / Itemize ──
                            FormCard(
                              children: [
                                Text('Location', style: FormTextStyles.label()),
                                SizedBox(height: Dimensions.height10 / 2),
                                _selectorField(
                                  value: _location,
                                  hint: 'Select a location',
                                  onTap: _selectLocation,
                                ),
                                SizedBox(height: Dimensions.height20),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const RequiredLabel(text: 'Date'),
                                          SizedBox(
                                            height: Dimensions.height10 / 2,
                                          ),
                                          _dateField(
                                            formatDate(_expenseDate),
                                            _pickDate,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: Dimensions.width15),
                                    // ── AttachmentPicker ──────────────────
                                    AttachmentPicker(
                                      label: 'Attach\nReceipt',
                                      initialFiles: _receipts,
                                      onChanged: (files) {
                                        setState(
                                          () => _receipts = files.toList(),
                                        );
                                        markDirty();
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: Dimensions.height20),

                                const RequiredLabel(text: 'Expense Account'),
                                SizedBox(height: Dimensions.height10 / 2),
                                _selectorField(
                                  value: _expenseAccount,
                                  hint: 'Select Expense Account',
                                  onTap: _selectExpenseAccount,
                                ),
                                SizedBox(height: Dimensions.height20),

                                const RequiredLabel(text: 'Paid Through'),
                                SizedBox(height: Dimensions.height10 / 2),
                                _selectorField(
                                  value: _paidThrough,
                                  hint: 'Select account',
                                  onTap: _selectPaidThrough,
                                ),
                                SizedBox(height: Dimensions.height20),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Itemize',
                                      style: TextStyle(
                                        fontSize: Dimensions.font16 * 0.95,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Switch(
                                      value: _itemize,
                                      onChanged: (v) {
                                        setState(() => _itemize = v);
                                        markDirty();
                                      },
                                      activeTrackColor: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: Dimensions.height15),

                            // ── Card 2: Amount / Reference ──
                            FormCard(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const RequiredLabel(text: 'Amount'),
                                    FormNumberField(
                                      controller: _amountController,
                                      hint: '0.00',
                                      prefix: 'INR',
                                    ),
                                  ],
                                ),
                                SizedBox(height: Dimensions.height20),

                                Text(
                                  'Reference',
                                  style: FormTextStyles.label(),
                                ),
                                SizedBox(height: Dimensions.height10 / 2),
                                TextField(
                                  controller: _referenceController,
                                  style: FormTextStyles.value(context),
                                  decoration: _underlineDecoration(),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimensions.height15),

                            // ── Card 3: Vendor / Invoice# / Notes / Customer / Tags ──
                            FormCard(
                              children: [
                                Text('Vendor', style: FormTextStyles.label()),
                                SizedBox(height: Dimensions.height10 / 2),
                                _searchSelectorField(
                                  value: _vendorName,
                                  hint: 'Start typing to select a Vendor',
                                  onTap: _selectVendor,
                                ),
                                SizedBox(height: Dimensions.height20),

                                Text('Invoice#', style: FormTextStyles.label()),
                                SizedBox(height: Dimensions.height10 / 2),
                                TextField(
                                  controller: _invoiceController,
                                  style: FormTextStyles.value(context),
                                  decoration: _underlineDecoration(),
                                ),
                                SizedBox(height: Dimensions.height20),

                                Text('Notes', style: FormTextStyles.label()),
                                SizedBox(height: Dimensions.height10 / 2),
                                TextField(
                                  controller: _notesController,
                                  style: FormTextStyles.value(context),
                                  maxLines: 3,
                                  minLines: 1,
                                  decoration: _underlineDecoration(),
                                ),
                                SizedBox(height: Dimensions.height20),

                                Text('Customer', style: FormTextStyles.label()),
                                SizedBox(height: Dimensions.height10 / 2),
                                _searchSelectorField(
                                  value: _customer,
                                  hint: 'Start typing to select a Customer',
                                  onTap: _selectCustomer,
                                ),
                                SizedBox(height: Dimensions.height20),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Reporting Tags',
                                      style: FormTextStyles.label(),
                                    ),
                                    GestureDetector(
                                      onTap: _selectReportingTags,
                                      child: Text(
                                        'Associate Tags',
                                        style: TextStyle(
                                          fontSize: Dimensions.font16 * 0.85,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_reportingTags.isNotEmpty) ...[
                                  SizedBox(height: Dimensions.height10),
                                  Wrap(
                                    spacing: Dimensions.width10 / 2,
                                    runSpacing: Dimensions.height10 / 2,
                                    children: _reportingTags.map((tag) {
                                      return Chip(
                                        label: Text(
                                          tag,
                                          style: TextStyle(
                                            fontSize: Dimensions.font16 * 0.78,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        backgroundColor: AppColors.primary
                                            .withValues(alpha: 0.08),
                                        side: BorderSide(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                        deleteIcon: Icon(
                                          Icons.close_rounded,
                                          size: Dimensions.iconSize24 * 0.7,
                                          color: AppColors.primary,
                                        ),
                                        onDeleted: () {
                                          setState(
                                            () => _reportingTags.remove(tag),
                                          );
                                          markDirty();
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: Dimensions.width10 / 2,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: Dimensions.height30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Form helpers ────────────────────────────────────────────────────────────

  InputDecoration _underlineDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: Dimensions.height10),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: context.colors.border),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: context.colors.border),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _selectorField({
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.colors.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.9,
                  color: value == null
                      ? context.colors.textTertiary
                      : context.colors.textPrimary,
                  fontWeight: value == null
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: Dimensions.iconSize24,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.colors.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: FormTextStyles.value(context)),
            Icon(
              Icons.calendar_today_outlined,
              size: Dimensions.iconSize24 * 0.85,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchSelectorField({
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.colors.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.9,
                  color: value == null
                      ? context.colors.textTertiary
                      : context.colors.textPrimary,
                  fontWeight: value == null
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.add_rounded,
              size: Dimensions.iconSize24,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reporting Tags multi-select bottom sheet ───────────────────────────────────

class _ReportingTagsSheet extends StatefulWidget {
  final List<String> options;
  final List<String> selected;

  const _ReportingTagsSheet({required this.options, required this.selected});

  @override
  State<_ReportingTagsSheet> createState() => _ReportingTagsSheetState();
}

class _ReportingTagsSheetState extends State<_ReportingTagsSheet> {
  late final List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(Dimensions.width15),
            child: Text(
              'Reporting Tags',
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
              children: widget.options.map((tag) {
                final isSelected = _selected.contains(tag);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(
                    tag,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : context.colors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: Dimensions.font16 * 0.9,
                    ),
                  ),
                  fillColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.primary
                        : null,
                  ),
                  checkColor: Colors.white,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selected.add(tag);
                      } else {
                        _selected.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width15,
              vertical: Dimensions.height15,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: Dimensions.height15 * 0.9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radius15 / 2,
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context, _selected),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: Dimensions.font16 * 0.95,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
