import 'dart:io';

import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/bottom_sheet_drag_handle.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/expenses/models/expense_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final List<_AttachmentFile> _receipts = [];
  static const int _maxReceipts = 5;
  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB
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

  /// Simulates preparing the form so the shimmer skeleton is shown briefly.
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
                children: [
                  ...options.map(
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
                          ? Icon(Icons.check_rounded, color: AppColors.primary)
                          : null,
                      onTap: () => Navigator.pop(context, option),
                    ),
                  ),
                ],
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
                            // ── Card 1: Location / Date / Expense Account / Paid Through / Itemize ──
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
                                    _attachReceiptButton(),
                                  ],
                                ),
                                if (_receipts.isNotEmpty) ...[
                                  SizedBox(height: Dimensions.height15),
                                  _receiptThumbnails(),
                                ],
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

                            // ── Card 3: Vendor / Invoice# / Notes / Customer / Reporting Tags ──
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
                                    children: _reportingTags
                                        .map(
                                          (tag) => Chip(
                                            label: Text(
                                              tag,
                                              style: TextStyle(
                                                fontSize:
                                                    Dimensions.font16 * 0.78,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            backgroundColor: AppColors.primary
                                                .withValues(alpha: 0.08),
                                            side: BorderSide(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.3),
                                            ),
                                            deleteIcon: Icon(
                                              Icons.close_rounded,
                                              size: Dimensions.iconSize24 * 0.7,
                                              color: AppColors.primary,
                                            ),
                                            onDeleted: () {
                                              setState(
                                                () =>
                                                    _reportingTags.remove(tag),
                                              );
                                              markDirty();
                                            },
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.width10 / 2,
                                            ),
                                          ),
                                        )
                                        .toList(),
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

  // ── Receipt attachment ────────────────────────────────────────────────────

  Future<void> _showAttachReceiptSheet() async {
    if (_receipts.length >= _maxReceipts) {
      ToastificationHelper.showWarning(
        context,
        'Maximum $_maxReceipts attachments allowed.',
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BottomSheetDragHandle(),
              SizedBox(height: Dimensions.height10 / 2),
              Text(
                'Attach Receipt',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 1.05,
                  fontWeight: FontWeight.w700,
                  color: sheetCtx.colors.textPrimary,
                ),
              ),
              SizedBox(height: Dimensions.height10 / 2),
              Text(
                'Up to $_maxReceipts files · max 10 MB each'
                '  (${_receipts.length}/$_maxReceipts used)',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.75,
                  color: sheetCtx.colors.textSecondary,
                ),
              ),
              SizedBox(height: Dimensions.height20),
              _sheetOption(
                sheetCtx,
                icon: Icons.camera_alt_outlined,
                label: 'Take a Photo',
                subtitle: 'Use your camera',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pickFromCamera();
                },
              ),
              SizedBox(height: Dimensions.height10),
              _sheetOption(
                sheetCtx,
                icon: Icons.photo_library_outlined,
                label: 'Select from Device',
                subtitle: 'Choose a photo from your gallery',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pickFromGallery();
                },
              ),
              SizedBox(height: Dimensions.height10),
              _sheetOption(
                sheetCtx,
                icon: Icons.insert_drive_file_outlined,
                label: 'Select from Documents',
                subtitle: 'PDF, Word, or other files',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _pickFromFiles();
                },
              ),
              SizedBox(height: Dimensions.height10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      child: Container(
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: ctx.colors.surfaceLight,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(color: ctx.colors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Dimensions.width10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: Dimensions.iconSize24,
              ),
            ),
            SizedBox(width: Dimensions.width15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.9,
                      fontWeight: FontWeight.w700,
                      color: ctx.colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.75,
                      color: ctx.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final remaining = _maxReceipts - _receipts.length;
    if (remaining <= 0) {
      ToastificationHelper.showWarning(
        context,
        'Maximum $_maxReceipts attachments already reached.',
      );
      return;
    }
    try {
      final results = await Navigator.push<List<XFile>>(
        context,
        MaterialPageRoute(
          builder: (_) => _CameraReviewPage(maxPhotos: remaining),
          fullscreenDialog: true,
        ),
      );
      if (results == null || results.isEmpty) return;
      for (final xFile in results) {
        await _addAttachment(_AttachmentFile.fromXFile(xFile));
      }
    } catch (_) {
      if (mounted) {
        ToastificationHelper.showError(
          context,
          'Could not open camera. Please try again.',
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked == null) return;
      await _addAttachment(_AttachmentFile.fromXFile(picked));
    } catch (_) {
      if (mounted) {
        ToastificationHelper.showError(
          context,
          'Could not open gallery. Please try again.',
        );
      }
    }
  }

  Future<void> _pickFromFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
        ],
      );
      if (result == null || result.files.isEmpty) return;

      final remaining = _maxReceipts - _receipts.length;
      final toAdd = result.files.take(remaining).toList();

      if (result.files.length > remaining) {
        if (mounted) {
          ToastificationHelper.showWarning(
            context,
            'Only $remaining more attachment(s) allowed. '
            'Extra files were skipped.',
          );
        }
      }

      for (final pf in toAdd) {
        if (pf.path == null) continue;
        await _addAttachment(_AttachmentFile.fromPlatformFile(pf));
      }
    } catch (_) {
      if (mounted) {
        ToastificationHelper.showError(
          context,
          'Could not open file picker. Please try again.',
        );
      }
    }
  }

  Future<void> _addAttachment(_AttachmentFile file) async {
    // Guard: limit
    if (_receipts.length >= _maxReceipts) {
      if (mounted) {
        ToastificationHelper.showWarning(
          context,
          'Maximum $_maxReceipts attachments allowed.',
        );
      }
      return;
    }
    // Guard: size
    final size = await file.sizeInBytes();
    if (size > _maxFileSizeBytes) {
      if (mounted) {
        ToastificationHelper.showWarning(
          context,
          '"${file.name}" exceeds the 10 MB limit and was not added.',
        );
      }
      return;
    }
    if (mounted) {
      setState(() => _receipts.add(file));
      markDirty();
    }
  }

  void _removeAttachment(int index) {
    setState(() => _receipts.removeAt(index));
    markDirty();
  }

  Widget _receiptThumbnails() {
    return Wrap(
      spacing: Dimensions.width10,
      runSpacing: Dimensions.height10,
      children: _receipts.asMap().entries.map((entry) {
        final index = entry.key;
        final file = entry.value;
        return _thumbnailChip(file, index);
      }).toList(),
    );
  }

  Widget _thumbnailChip(_AttachmentFile file, int index) {
    final isImage = file.isImage;
    return Container(
      width: Dimensions.height45 * 1.8,
      height: Dimensions.height45 * 1.8,
      decoration: BoxDecoration(
        color: context.colors.surfaceLight,
        borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
        border: Border.all(color: context.colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isImage)
            Image.file(
              File(file.path),
              fit: BoxFit.cover,
              errorBuilder: (_, e, stack) => _filePlaceholder(file),
            )
          else
            _filePlaceholder(file),
          Positioned(
            top: Dimensions.height10 * 0.4,
            right: Dimensions.width10 * 0.4,
            child: GestureDetector(
              onTap: () => _removeAttachment(index),
              child: Container(
                padding: EdgeInsets.all(Dimensions.height10 * 0.35),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: Dimensions.iconSize16 * 0.85,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filePlaceholder(_AttachmentFile file) {
    return Container(
      color: context.colors.surfaceLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            file.isPdf
                ? Icons.picture_as_pdf_rounded
                : Icons.insert_drive_file_rounded,
            color: context.colors.textSecondary,
            size: Dimensions.iconSize24 * 1.2,
          ),
          SizedBox(height: Dimensions.height10 / 3),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width10 / 2),
            child: Text(
              file.extension.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.65,
                fontWeight: FontWeight.w600,
                color: context.colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachReceiptButton() {
    return GestureDetector(
      onTap: _showAttachReceiptSheet,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: Dimensions.height45 * 1.8,
            height: Dimensions.height45 * 1.8,
            decoration: BoxDecoration(
              border: Border.all(
                color: context.colors.border,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
              color: context.colors.surfaceLight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.attach_file_rounded,
                  color: context.colors.textSecondary,
                  size: Dimensions.iconSize24,
                ),
                SizedBox(height: Dimensions.height10 / 4),
                Text(
                  'Attach\nReceipt',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.7,
                    color: context.colors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (_receipts.isNotEmpty)
            Positioned(
              top: -Dimensions.height10 * 0.6,
              right: -Dimensions.width10 * 0.6,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10 * 0.7,
                  vertical: Dimensions.height10 * 0.4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                ),
                child: Text(
                  '${_receipts.length}',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.7,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// A selector field with a '+' icon on the right (for search-style selectors
  /// like Vendor and Customer).
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

// ── Camera review page ────────────────────────────────────────────────────────

/// Lets the user take multiple photos in sequence before confirming.
/// Returns a [List<XFile>] when the user taps Done, or null/empty on cancel.
class _CameraReviewPage extends StatefulWidget {
  final int maxPhotos;
  const _CameraReviewPage({required this.maxPhotos});

  @override
  State<_CameraReviewPage> createState() => _CameraReviewPageState();
}

class _CameraReviewPageState extends State<_CameraReviewPage> {
  final List<XFile> _photos = [];
  bool _isTaking = false;

  @override
  void initState() {
    super.initState();
    // Immediately open camera for the first shot.
    WidgetsBinding.instance.addPostFrameCallback((_) => _takePhoto());
  }

  Future<void> _takePhoto() async {
    if (_isTaking) return;
    if (_photos.length >= widget.maxPhotos) {
      _done();
      return;
    }
    setState(() => _isTaking = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (!mounted) return;
      if (picked != null) {
        setState(() => _photos.add(picked));
      } else if (_photos.isEmpty) {
        // User cancelled on the very first shot — just go back.
        Navigator.pop(context, <XFile>[]);
      }
    } catch (_) {
      if (mounted && _photos.isEmpty) {
        Navigator.pop(context, <XFile>[]);
      }
    } finally {
      if (mounted) setState(() => _isTaking = false);
    }
  }

  void _done() => Navigator.pop(context, List<XFile>.from(_photos));

  void _removePhoto(int index) => setState(() => _photos.removeAt(index));

  @override
  Widget build(BuildContext context) {
    final last = _photos.isNotEmpty ? _photos.last : null;
    final canTakeMore = _photos.length < widget.maxPhotos;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width15,
                vertical: Dimensions.height10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel
                  GestureDetector(
                    onTap: () => Navigator.pop(context, <XFile>[]),
                    child: Container(
                      padding: EdgeInsets.all(Dimensions.width10 * 0.8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: Dimensions.iconSize24,
                      ),
                    ),
                  ),
                  // Counter label
                  if (_photos.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width15,
                        vertical: Dimensions.height10 * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius20,
                        ),
                      ),
                      child: Text(
                        '${_photos.length} / ${widget.maxPhotos}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Dimensions.font16 * 0.85,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  // Done button
                  if (_photos.isNotEmpty)
                    GestureDetector(
                      onTap: _done,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width15,
                          vertical: Dimensions.height10 * 0.6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
                        ),
                        child: Text(
                          'Done (${_photos.length})',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: Dimensions.font16 * 0.9,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(width: Dimensions.iconSize24 * 1.8),
                ],
              ),
            ),

            // ── Preview area ─────────────────────────────────────────────────
            Expanded(
              child: last == null
                  ? Center(
                      child: _isTaking
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'No photos yet',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: Dimensions.font16,
                              ),
                            ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(last.path), fit: BoxFit.contain),
                        if (_isTaking)
                          Container(
                            color: Colors.black38,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),

            // ── Thumbnail strip ───────────────────────────────────────────────
            if (_photos.length > 1)
              SizedBox(
                height: Dimensions.height45 * 1.5,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width15,
                    vertical: Dimensions.height10 * 0.5,
                  ),
                  itemCount: _photos.length,
                  separatorBuilder: (_, i) =>
                      SizedBox(width: Dimensions.width10 * 0.6),
                  itemBuilder: (ctx, i) {
                    final isLast = i == _photos.length - 1;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: Dimensions.height45 * 1.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius15 / 3,
                            ),
                            border: Border.all(
                              color: isLast
                                  ? AppColors.primary
                                  : Colors.white38,
                              width: isLast ? 2 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.file(
                            File(_photos[i].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Remove button on each thumbnail
                        Positioned(
                          top: -Dimensions.height10 * 0.5,
                          right: -Dimensions.width10 * 0.5,
                          child: GestureDetector(
                            onTap: () => _removePhoto(i),
                            child: Container(
                              padding: EdgeInsets.all(
                                Dimensions.height10 * 0.3,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: Dimensions.iconSize16 * 0.75,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // ── Bottom controls ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Take another photo button
                  if (canTakeMore)
                    GestureDetector(
                      onTap: _isTaking ? null : _takePhoto,
                      child: Container(
                        width: Dimensions.height45 * 1.6,
                        height: Dimensions.height45 * 1.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          color: _isTaking
                              ? Colors.white24
                              : Colors.white.withValues(alpha: 0.15),
                        ),
                        child: _isTaking
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: Dimensions.iconSize24 * 1.3,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AttachmentFile model ──────────────────────────────────────────────────────

class _AttachmentFile {
  final String path;
  final String name;
  final String extension;

  const _AttachmentFile({
    required this.path,
    required this.name,
    required this.extension,
  });

  factory _AttachmentFile.fromXFile(XFile xFile) {
    final name = xFile.name.isNotEmpty
        ? xFile.name
        : xFile.path.split(Platform.pathSeparator).last;
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return _AttachmentFile(path: xFile.path, name: name, extension: ext);
  }

  factory _AttachmentFile.fromPlatformFile(PlatformFile pf) {
    final ext = pf.extension?.toLowerCase() ?? '';
    return _AttachmentFile(path: pf.path!, name: pf.name, extension: ext);
  }

  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);

  bool get isPdf => extension == 'pdf';

  Future<int> sizeInBytes() async {
    try {
      return await File(path).length();
    } catch (_) {
      return 0;
    }
  }
}

// ── Reporting Tags multi-select bottom sheet ──────────────────────────────────

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
