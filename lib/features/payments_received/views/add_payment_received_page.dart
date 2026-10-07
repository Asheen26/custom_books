import 'dart:async';

import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/customers/controllers/customers_list_controller.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:custom_books/features/customers/widgets/customer_page_widgets/customer_card_widget.dart';
import 'package:custom_books/features/payments_received/controllers/payment_received_form_controller.dart';
import 'package:custom_books/features/payments_received/models/payment_received_model.dart';
import 'package:flutter/material.dart';
import 'package:custom_books/core/utils/date_formatter.dart';

class AddPaymentReceivedPage extends StatefulWidget {
  final PaymentReceivedModel? existing;

  const AddPaymentReceivedPage({super.key, this.existing});

  @override
  State<AddPaymentReceivedPage> createState() => _AddPaymentReceivedPageState();
}

class _AddPaymentReceivedPageState extends State<AddPaymentReceivedPage>
    with UnsavedChangesMixin {
  final _customerController = TextEditingController();
  final _paymentNumController = TextEditingController();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();

  /// UUID sent to the API — kept in sync with [_customerController].
  String? _selectedCustomerId;

  DateTime _paymentDate = DateTime.now();
  PaymentMode _mode = PaymentMode.bankTransfer;
  bool _isLoading = true;

  late final PaymentReceivedFormController _formController;

  @override
  void initState() {
    super.initState();
    _formController = PaymentReceivedFormController();
    _formController.addListener(_onControllerUpdate);

    _load();
    _paymentNumController.text = 'PR-00022';

    final existing = widget.existing;
    if (existing != null) {
      _selectedCustomerId = existing.customerId.isNotEmpty
          ? existing.customerId
          : null;
      _customerController.text = existing.customerName;
      _paymentNumController.text = existing.paymentNumber;
      _referenceController.text = existing.referenceNumber;
      _amountController.text = existing.amount.toStringAsFixed(2);
      _paymentDate = existing.paymentDate;
      _mode = existing.mode;
    }

    _customerController.addListener(markDirty);
    _paymentNumController.addListener(markDirty);
    _referenceController.addListener(markDirty);
    _amountController.addListener(markDirty);
  }

  @override
  void dispose() {
    _formController.removeListener(_onControllerUpdate);
    _formController.dispose();

    _customerController.removeListener(markDirty);
    _paymentNumController.removeListener(markDirty);
    _referenceController.removeListener(markDirty);
    _amountController.removeListener(markDirty);

    _customerController.dispose();
    _paymentNumController.dispose();
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  /// Brief shimmer so the form doesn't flash empty on open.
  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _paymentDate = picked);
      markDirty();
    }
  }

  Future<void> _selectCustomer() async {
    final picked = await Navigator.push<CustomerModel>(
      context,
      MaterialPageRoute(builder: (_) => const _CustomerPickerPage()),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedCustomerId = picked.id;
        _customerController.text = picked.name;
      });
      markDirty();
    }
  }

  Future<void> _selectMode() async {
    final selected = await showModalBottomSheet<PaymentMode>(
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
                'Payment Mode',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 1.1,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            ...PaymentMode.values.map(
              (mode) => ListTile(
                title: Text(
                  mode.label,
                  style: TextStyle(
                    color: mode == _mode
                        ? AppColors.primary
                        : context.colors.textPrimary,
                    fontWeight: mode == _mode
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: mode == _mode
                    ? Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, mode),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() => _mode = selected);
      markDirty();
    }
  }

  Future<void> _savePayment() async {
    // ── validation ────────────────────────────────────────────────────────────
    if (_selectedCustomerId == null || _selectedCustomerId!.isEmpty) {
      ToastificationHelper.showWarning(context, 'Please select a Customer.');
      return;
    }
    if (_paymentNumController.text.trim().isEmpty) {
      ToastificationHelper.showWarning(
        context,
        'Please enter a Payment Number.',
      );
      return;
    }
    if (_amountController.text.trim().isEmpty) {
      ToastificationHelper.showWarning(context, 'Please enter an Amount.');
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ToastificationHelper.showWarning(context, 'Please enter a valid Amount.');
      return;
    }

    // ── API call ──────────────────────────────────────────────────────────────
    final existing = widget.existing;
    final result = existing != null
        ? await _formController.update(
            paymentId: existing.id,
            customerId: _selectedCustomerId!,
            paymentDate: _paymentDate,
            paymentMode: _mode,
            referenceNumber: _referenceController.text.trim(),
            amount: amount,
          )
        : await _formController.create(
            customerId: _selectedCustomerId!,
            paymentDate: _paymentDate,
            paymentMode: _mode,
            referenceNumber: _referenceController.text.trim(),
            amount: amount,
          );

    if (!mounted) return;

    if (result.error != null) {
      ToastificationHelper.showError(context, result.error!);
      return;
    }

    // ── success ───────────────────────────────────────────────────────────────
    markClean();
    Navigator.pop(context, result.payment);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = _formController.isSaving;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: CustomBackAppBar(
          title: widget.existing == null ? 'New Payment' : 'Edit Payment',
          backgroundColor: context.colors.card,
          onLeadingPressed: () => onPopInvokedWithResult(false, null),
          actions: [
            TextButton(
              onPressed: isSaving ? null : _savePayment,
              child: isSaving
                  ? SizedBox(
                      width: Dimensions.iconSize24 * 0.75,
                      height: Dimensions.iconSize24 * 0.75,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Text(
                      'SAVE',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: Dimensions.font16 * 0.75,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ],
        ),
        body: _isLoading
            ? const FormPageSkeleton()
            : SingleChildScrollView(
                padding: EdgeInsets.all(Dimensions.width15),
                child: Column(
                  children: [
                    FormCard(
                      children: [
                        // ── Customer Name ─────────────────────────────────
                        const RequiredLabel(text: 'Customer Name'),
                        SizedBox(height: Dimensions.height10 / 2),
                        InkWell(
                          onTap: isSaving ? null : _selectCustomer,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width10 / 2,
                              vertical: Dimensions.height10,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: context.colors.border,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _customerController.text.isEmpty
                                        ? 'Start typing to select a Customer'
                                        : _customerController.text,
                                    style: TextStyle(
                                      fontSize: Dimensions.font16 * 0.9,
                                      color: _customerController.text.isEmpty
                                          ? context.colors.textTertiary
                                          : context.colors.textPrimary,
                                      fontWeight:
                                          _customerController.text.isEmpty
                                          ? FontWeight.normal
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.add_rounded,
                                  size: Dimensions.iconSize24,
                                  color: context.colors.textPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),

                        // ── Payment# ──────────────────────────────────────
                        const RequiredLabel(text: 'Payment#'),
                        SizedBox(height: Dimensions.height10 / 2),
                        TextField(
                          controller: _paymentNumController,
                          style: FormTextStyles.value(context),
                          enabled: !isSaving,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: Dimensions.height10,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: context.colors.border,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: context.colors.border,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),

                        // ── Payment Date ──────────────────────────────────
                        const RequiredLabel(text: 'Payment Date'),
                        SizedBox(height: Dimensions.height10 / 2),
                        InkWell(
                          onTap: isSaving ? null : _pickDate,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height10,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: context.colors.border,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatDate(_paymentDate),
                                  style: FormTextStyles.value(context),
                                ),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: Dimensions.iconSize24 * 0.85,
                                  color: context.colors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),

                        // ── Payment Mode ──────────────────────────────────
                        Text('Payment Mode', style: FormTextStyles.label()),
                        SizedBox(height: Dimensions.height10 / 2),
                        InkWell(
                          onTap: isSaving ? null : _selectMode,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height10,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: context.colors.border,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _mode.label,
                                  style: FormTextStyles.value(context),
                                ),
                                Icon(
                                  Icons.arrow_drop_down_rounded,
                                  size: Dimensions.iconSize24,
                                  color: context.colors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),

                        // ── Reference# ────────────────────────────────────
                        Text('Reference#', style: FormTextStyles.label()),
                        SizedBox(height: Dimensions.height10 / 2),
                        TextField(
                          controller: _referenceController,
                          style: FormTextStyles.value(context),
                          enabled: !isSaving,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: Dimensions.height10,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: context.colors.border,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: context.colors.border,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),

                        // ── Amount (₹) ────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const RequiredLabel(text: 'Amount (₹)'),
                            FormNumberField(
                              controller: _amountController,
                              hint: '0.00',
                              prefix: '₹',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lightweight customer picker — loads from the API and pops with CustomerModel.
// ---------------------------------------------------------------------------

class _CustomerPickerPage extends StatefulWidget {
  const _CustomerPickerPage();

  @override
  State<_CustomerPickerPage> createState() => _CustomerPickerPageState();
}

class _CustomerPickerPageState extends State<_CustomerPickerPage> {
  final CustomersListController _ctrl = CustomersListController();
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_refresh);
    _scroll.addListener(_onScroll);
    _ctrl.loadFirstPage();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _ctrl.removeListener(_refresh);
    _ctrl.dispose();
    _search.dispose();
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

  void _onSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _ctrl.loadFirstPage(search: _search.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.card,
        title: Text(
          'Select Customer',
          style: TextStyle(
            fontSize: Dimensions.font16,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              0,
              Dimensions.width20,
              Dimensions.height10,
            ),
            child: TextField(
              controller: _search,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search customers…',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: context.colors.surfaceLight,
              ),
            ),
          ),
        ),
      ),
      body: _ctrl.isLoading && _ctrl.customers.isEmpty
          ? const CustomerListSkeleton()
          : _ctrl.customers.isEmpty
          ? const Center(child: Text('No customers found'))
          : ListView.builder(
              controller: _scroll,
              padding: EdgeInsets.all(Dimensions.width20),
              itemCount: _ctrl.customers.length + (_ctrl.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _ctrl.customers.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }
                final customer = _ctrl.customers[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: Dimensions.height10),
                  child: CustomerCardWidget(
                    customer: customer,
                    onTap: () => Navigator.pop(context, customer),
                  ),
                );
              },
            ),
    );
  }
}
