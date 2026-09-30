import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/dashed_border.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/core/widgets/line_item_form_widgets.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/inventory_adjustments/widgets/adjustment_form_widgets.dart';
import 'package:custom_books/features/quotes/controllers/quote_form_controller.dart';
import 'package:custom_books/features/quotes/models/quote_model.dart';
import 'package:custom_books/features/quotes/views/add_quote_line_item_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:custom_books/core/utils/date_formatter.dart';

class AddQuotePage extends StatefulWidget {
  final int quoteSequence;

  const AddQuotePage({super.key, this.quoteSequence = 2});

  @override
  State<AddQuotePage> createState() => _AddQuotePageState();
}

class _AddQuotePageState extends State<AddQuotePage> with UnsavedChangesMixin {
  final _formController = QuoteFormController();
  final _customer = TextEditingController();
  final _reference = TextEditingController();
  final _subject = TextEditingController();
  final _notes = TextEditingController(
    text: 'Looking forward for your business.',
  );
  final _terms = TextEditingController();
  final List<QuoteLineItem> _lineItems = [];
  final List<PlatformFile> _attachments = [];
  late String _quoteNumber;
  DateTime _quoteDate = DateTime.now();
  DateTime? _expiryDate;
  String? _salesperson;
  String? _project;
  bool _taxInclusive = false;
  bool _isLoading = true;

  String? _selectedCustomerId;

  static const _salespeople = ['Own Store', 'Parthiv P', 'Aarav Menon'];

  @override
  void initState() {
    super.initState();
    _load();
    _quoteNumber = 'QT-${widget.quoteSequence.toString().padLeft(6, '0')}';
    _customer.addListener(markDirty);
    _reference.addListener(markDirty);
    _subject.addListener(markDirty);
    _notes.addListener(markDirty);
    _terms.addListener(markDirty);
  }

  @override
  void dispose() {
    _formController.dispose();
    _customer.removeListener(markDirty);
    _reference.removeListener(markDirty);
    _subject.removeListener(markDirty);
    _notes.removeListener(markDirty);
    _terms.removeListener(markDirty);
    _customer.dispose();
    _reference.dispose();
    _subject.dispose();
    _notes.dispose();
    _terms.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _pickDate(bool expiry) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expiry
          ? (_expiryDate ?? _quoteDate.add(const Duration(days: 30)))
          : _quoteDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => expiry ? _expiryDate = picked : _quoteDate = picked);
    }
  }

  Future<void> _selectCustomer() async {
    const mockCustomers = [
      {'id': 'ed63974e-1057-492a-a47d-d55cbf8ed2e7', 'name': 'Acme Traders'},
      {'id': 'amal-id-placeholder', 'name': 'Amal'},
      {'id': 'nabeel-id-placeholder', 'name': 'Nabeel'},
      {'id': 'nandhu-id-placeholder', 'name': 'Nandhu'},
      {'id': 'parthiv-id-placeholder', 'name': 'Parthiv Ajith'},
    ];

    final selected = await showModalBottomSheet<Map<String, String>>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Select Customer',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ...mockCustomers.map(
              (c) => ListTile(
                leading: CircleAvatar(
                  child: Text((c['name'] ?? '').substring(0, 1).toUpperCase()),
                ),
                title: Text(c['name'] ?? ''),
                onTap: () => Navigator.pop(
                  context,
                  {'id': c['id']!, 'name': c['name']!},
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_rounded, color: AppColors.primary),
              title: const Text('Add New Customer'),
              onTap: () => Navigator.pop(context, null),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        _customer.text = selected['name'] ?? '';
        _selectedCustomerId = selected['id'];
      });
    }
  }

  Future<void> _addLineItem() async {
    final result = await Navigator.push<Object>(
      context,
      MaterialPageRoute(builder: (_) => const AddQuoteLineItemPage()),
    );
    if (!mounted || result == null) return;
    if (result is QuoteLineItem) {
      setState(() => _lineItems.add(result));
    } else if (result is List<QuoteLineItem> && result.isNotEmpty) {
      setState(() => _lineItems.add(result.first));
      await _addLineItem();
    }
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    final existing = _attachments.map((file) => file.name).toSet();
    setState(
      () => _attachments.addAll(
        result.files.where((file) => existing.add(file.name)),
      ),
    );
  }

  Future<void> _save({QuoteStatus status = QuoteStatus.draft}) async {
    if (_formController.isSaving) return;

    if (_customer.text.trim().isEmpty || _selectedCustomerId == null) {
      ToastificationHelper.showWarning(context, 'Please select a customer.');
      return;
    }
    if (_lineItems.isEmpty) {
      ToastificationHelper.showWarning(
        context,
        'Please add at least one line item.',
      );
      return;
    }

    final body = <String, dynamic>{
      'customer_id': _selectedCustomerId,
      'quote_date':
          '${_quoteDate.year}-${_quoteDate.month.toString().padLeft(2, '0')}-${_quoteDate.day.toString().padLeft(2, '0')}',
      'subject': _subject.text.trim(),
      'tax_type': _taxInclusive ? 'inclusive' : 'exclusive',
      'customer_notes': _notes.text.trim(),
      'terms_and_conditions': _terms.text.trim(),
      'action': status == QuoteStatus.sent ? 'save_and_send' : 'save_as_draft',
      'line_items': _lineItems
          .map((item) => {
                'name': item.itemName,
                'quantity': item.quantity.toString(),
                'rate': item.rate.toStringAsFixed(2),
                if (item.description.isNotEmpty)
                  'description': item.description,
              })
          .toList(),
      if (_reference.text.trim().isNotEmpty)
        'reference_number': _reference.text.trim(),
    };

    setState(() {}); // Refresh UI to reflect isSaving = true.
    final success = await _formController.create(body);
    if (!mounted) return;

    if (success) {
      markClean();
      final quote = _formController.savedQuote;
      final msg = status == QuoteStatus.sent
          ? 'Quote sent successfully.'
          : 'Quote saved as draft.';
      ToastificationHelper.showSuccess(context, msg);
      Navigator.pop(context, quote);
    } else {
      setState(() {});
      ToastificationHelper.showError(
        context,
        _formController.errorMessage ?? 'Could not save the quote.',
      );
    }
  }

  Future<void> _configureNumber() async {
    final controller = TextEditingController(text: _quoteNumber);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quote Number'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Number'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              backgroundColor: Colors.transparent,
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null && value.isNotEmpty) setState(() => _quoteNumber = value);
  }

  Widget _card(List<Widget> children) => Padding(
    padding: EdgeInsets.only(bottom: Dimensions.height15),
    child: FormCard(
      borderRadius: Dimensions.radius20,
      showShadow: true,
      children: children,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: CustomBackAppBar(
          title: 'Add Quote',
          onLeadingPressed: () => onPopInvokedWithResult(false, null),
          actions: [
            TextButton(
              onPressed: _formController.isSaving
                  ? null
                  : () => _save(),
              child: Text(
                _formController.isSaving ? 'SAVING…' : 'SAVE AS DRAFT',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.75,
                  fontWeight: FontWeight.w700,
                  color: _formController.isSaving
                      ? context.colors.textTertiary
                      : AppColors.primary,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: context.colors.textSecondary,
                size: Dimensions.iconSize24 - 4,
              ),
              onSelected: _formController.isSaving
                  ? null
                  : (value) {
                      if (value == 'send') {
                        _save(status: QuoteStatus.sent);
                      }
                      if (value == 'clear') {
                        setState(() {
                          _customer.clear();
                          _selectedCustomerId = null;
                          _reference.clear();
                          _subject.clear();
                          _lineItems.clear();
                          _attachments.clear();
                        });
                      }
                    },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'send', child: Text('Save and Send')),
                PopupMenuItem(value: 'clear', child: Text('Clear Form')),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? const FormPageSkeleton()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    Dimensions.height15,
                    Dimensions.width20,
                    Dimensions.height30,
                  ),
                  child: Column(
                    children: [
                      _card([
                        FormLabel(text: 'Customer Name ', required: true),
                        InkWell(
                          onTap: _selectCustomer,
                          child: IgnorePointer(
                            child: TextField(
                              controller: _customer,
                              decoration: FormTextStyles.inputDecoration(
                                context,
                                'Start typing to select a Customer',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: _selectCustomer,
                                ),
                              ),
                            ),
                          ),
                        ),
                        FormLabel(text: 'Quote # ', required: true),
                        TextField(
                          controller: TextEditingController(text: _quoteNumber),
                          readOnly: true,
                          decoration: FormTextStyles.inputDecoration(
                            context,
                            'e.g. QT-00001',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: _configureNumber,
                            ),
                          ),
                        ),
                        FormLabel(text: 'Reference#'),
                        TextField(
                          controller: _reference,
                          decoration: FormTextStyles.inputDecoration(
                            context,
                            '',
                          ),
                        ),
                        FormLabel(text: 'Quote Date ', required: true),
                        InkWell(
                          onTap: () => _pickDate(false),
                          child: IgnorePointer(
                            child: TextField(
                              controller: TextEditingController(
                                text: formatDate(_quoteDate),
                              ),
                              decoration: FormTextStyles.inputDecoration(
                                context,
                                'Select date',
                                suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                ),
                              ),
                            ),
                          ),
                        ),
                        FormLabel(text: 'Expiry Date'),
                        InkWell(
                          onTap: () => _pickDate(true),
                          child: IgnorePointer(
                            child: TextField(
                              controller: TextEditingController(
                                text: _expiryDate == null
                                    ? ''
                                    : formatDate(_expiryDate!),
                              ),
                              decoration: FormTextStyles.inputDecoration(
                                context,
                                'Select date',
                                suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                      _card([
                        FormLabel(text: 'Salesperson'),
                        DropdownButtonFormField<String>(
                          initialValue: _salesperson,
                          decoration: FormTextStyles.inputDecoration(
                            context,
                            'Select or Add Salesperson',
                          ),
                          items: _salespeople
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _salesperson = value),
                        ),
                        FormLabel(text: 'Project Name'),
                        DropdownButtonFormField<String>(
                          initialValue: _project,
                          decoration: FormTextStyles.inputDecoration(
                            context,
                            'Select a Project',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Website Redesign',
                              child: Text('Website Redesign'),
                            ),
                            DropdownMenuItem(
                              value: 'Annual Support',
                              child: Text('Annual Support'),
                            ),
                          ],
                          onChanged: _customer.text.isEmpty
                              ? null
                              : (value) => setState(() => _project = value),
                        ),
                        if (_customer.text.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                              top: Dimensions.height10 * 0.6,
                            ),
                            child: Text(
                              'Select a customer to associate a project.',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.75,
                              ),
                            ),
                          ),
                        FormLabel(text: 'Subject', showInfo: true),
                        TextField(
                          controller: _subject,
                          decoration: FormTextStyles.inputDecoration(
                            context,
                            'What is this quote for?',
                          ),
                        ),
                      ]),
                      _card([
                        Text('Tax', style: FormTextStyles.label()),
                        SizedBox(height: Dimensions.height10),
                        Container(
                          padding: EdgeInsets.all(Dimensions.height10 * 0.4),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceLight,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius15,
                            ),
                            border: Border.all(color: context.colors.border),
                          ),
                          child: Row(
                            children: [
                              _taxOption('Exclusive', false),
                              _taxOption('Inclusive', true),
                            ],
                          ),
                        ),
                      ]),
                      _card([
                        ..._lineItems.asMap().entries.map(
                          (entry) => _quoteLineItemCard(entry.key, entry.value),
                        ),
                        AddLineItemButton(onPressed: _addLineItem),
                        if (_lineItems.isNotEmpty) ...[
                          SizedBox(height: Dimensions.height20),
                          Container(
                            padding: EdgeInsets.all(Dimensions.width15),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius15,
                              ),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                _totalRow(
                                  'Sub Total',
                                  _lineItems.fold<double>(
                                    0,
                                    (sum, item) => sum + item.net,
                                  ),
                                ),
                                _totalRow(
                                  'Tax',
                                  _lineItems.fold<double>(
                                    0,
                                    (sum, item) => sum + item.taxAmount,
                                  ),
                                ),
                                const FormDivider(),
                                _totalRow(
                                  'Total',
                                  _lineItems.fold<double>(
                                    0,
                                    (sum, item) =>
                                        sum +
                                        item.net +
                                        (_taxInclusive ? 0 : item.taxAmount),
                                  ),
                                  bold: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ]),
                      _card([
                        FormLabel(text: 'Customer Notes'),
                        TextField(
                          controller: _notes,
                          decoration: FormTextStyles.inputDecoration(
                            context,
                            'Looking forward for your business.',
                          ),
                        ),
                        FormLabel(text: 'Terms & Conditions'),
                        TextField(
                          controller: _terms,
                          maxLines: 2,
                          decoration: FormTextStyles.inputDecoration(
                            context,
                            '',
                          ),
                        ),
                      ]),
                      _card([
                        Row(
                          children: [
                            Text('Attachments', style: FormTextStyles.label()),
                            if (_attachments.isNotEmpty) ...[
                              SizedBox(width: Dimensions.width10 / 2),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.width10 * 0.6,
                                  vertical: Dimensions.height10 * 0.2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  '${_attachments.length}',
                                  style: TextStyle(
                                    fontSize: Dimensions.font16 * 0.7,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: Dimensions.height10),
                        InkWell(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius15,
                          ),
                          onTap: _pickAttachments,
                          child: DashedBorder(
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: Dimensions.height15,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_file_outlined,
                                    color: AppColors.primary,
                                    size: Dimensions.iconSize24 - 4,
                                  ),
                                  SizedBox(width: Dimensions.width10),
                                  Text(
                                    _attachments.isEmpty
                                        ? 'Upload File'
                                        : 'Add More Files',
                                    style: TextStyle(
                                      fontSize: Dimensions.font16 * 0.85,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ..._attachments.asMap().entries.map(
                          (entry) => Container(
                            margin: EdgeInsets.only(top: Dimensions.height10),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceLight,
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius15,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.attach_file_rounded,
                                color: AppColors.primary,
                              ),
                              title: Text(
                                entry.value.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () => setState(
                                  () => _attachments.removeAt(entry.key),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _taxOption(String label, bool value) {
    final selected = _taxInclusive == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radius15 - 3),
        onTap: () => setState(() => _taxInclusive = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
          decoration: BoxDecoration(
            color: selected ? context.colors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(Dimensions.radius15 - 3),
            border: selected
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: Dimensions.radius15 * 0.53,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.8,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? AppColors.primary
                  : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _quoteLineItemCard(int index, QuoteLineItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height10),
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: context.colors.surfaceLight,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          ItemThumbnail(size: Dimensions.height45 * 0.8),
          SizedBox(width: Dimensions.width10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.85,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: Dimensions.height10 / 4),
                Text(
                  '${item.quantity.toStringAsFixed(2)} × ₹${item.rate.toStringAsFixed(2)}  •  ₹${item.net.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.68,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: Dimensions.iconSize24 - 6,
              color: context.colors.textTertiary,
            ),
            onPressed: () => setState(() => _lineItems.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) => Padding(
    padding: EdgeInsets.symmetric(vertical: Dimensions.height10 / 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.82,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: bold
                ? context.colors.textPrimary
                : context.colors.textSecondary,
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: Dimensions.font16 * (bold ? 0.95 : 0.82),
            fontWeight: FontWeight.w700,
            color: bold ? AppColors.primary : context.colors.textPrimary,
          ),
        ),
      ],
    ),
  );
}