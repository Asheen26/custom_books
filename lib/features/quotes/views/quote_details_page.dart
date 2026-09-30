import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/quotes/models/quote_model.dart';
import 'package:custom_books/features/quotes/views/add_quote_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuoteDetailsPage extends StatefulWidget {
  final QuoteModel quote;
  final ValueChanged<QuoteStatus>? onStatusChanged;
  final VoidCallback? onDelete;

  const QuoteDetailsPage({
    super.key,
    required this.quote,
    this.onStatusChanged,
    this.onDelete,
  });

  @override
  State<QuoteDetailsPage> createState() => _QuoteDetailsPageState();
}

class _QuoteDetailsPageState extends State<QuoteDetailsPage> {
  bool _isLoading = true;

  QuoteModel get quote => widget.quote;

  NumberFormat get _currency => NumberFormat.currency(
    symbol: '${quote.currency} ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomBackAppBar(
        title: 'Quote Details',
        backgroundColor: context.colors.card,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddQuotePage(quoteSequence: int.tryParse(
                      quote.quoteNumber.replaceAll(RegExp(r'[^0-9]'), ''),
                    ) ?? 1),
              ),
            ),
          ),
          _buildActionsMenu(context),
          SizedBox(width: Dimensions.width10),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const DetailsPageSkeleton(showTabs: false, showLineItems: true)
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(context),
                  SizedBox(height: Dimensions.height15),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                    ),
                    child: Column(
                      children: [
                        _buildInfoCard(context),
                        SizedBox(height: Dimensions.height15),
                        _buildLineItemsCard(context),
                        SizedBox(height: Dimensions.height15),
                        _buildTotalsCard(context),
                        if (quote.customerNotes.isNotEmpty) ...[
                          SizedBox(height: Dimensions.height15),
                          _buildNoteCard(
                            context,
                            'Customer Notes',
                            quote.customerNotes,
                          ),
                        ],
                        if (quote.termsAndConditions.isNotEmpty) ...[
                          SizedBox(height: Dimensions.height15),
                          _buildNoteCard(
                            context,
                            'Terms & Conditions',
                            quote.termsAndConditions,
                          ),
                        ],
                        SizedBox(height: Dimensions.height30),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: context.colors.textSecondary,
        size: Dimensions.iconSize24 - 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      surfaceTintColor: context.colors.card,
      color: context.colors.card,
      elevation: 8,
      onSelected: (value) {
        switch (value) {
          case 'mark_sent':
            widget.onStatusChanged?.call(QuoteStatus.sent);
            Navigator.pop(context);
          case 'mark_accepted':
            widget.onStatusChanged?.call(QuoteStatus.accepted);
            Navigator.pop(context);
          case 'mark_declined':
            widget.onStatusChanged?.call(QuoteStatus.declined);
            Navigator.pop(context);
          case 'convert':
            ToastificationHelper.showInfo(
              context,
              'Convert to invoice is coming soon.',
            );
          case 'print':
            ToastificationHelper.showInfo(
              context,
              'Printing quotes is coming soon.',
            );
          case 'delete':
            _confirmDelete(context);
        }
      },
      itemBuilder: (context) => [
        if (quote.status == QuoteStatus.draft)
          _menuItem(
            context,
            value: 'mark_sent',
            icon: Icons.send_outlined,
            label: 'Mark as Sent',
            color: AppColors.primaryLight,
          ),
        if (quote.status == QuoteStatus.sent) ...[
          _menuItem(
            context,
            value: 'mark_accepted',
            icon: Icons.check_circle_outline_rounded,
            label: 'Mark as Accepted',
            color: AppColors.success,
          ),
          _menuItem(
            context,
            value: 'mark_declined',
            icon: Icons.cancel_outlined,
            label: 'Mark as Declined',
            color: AppColors.error,
          ),
        ],
        if (quote.status == QuoteStatus.accepted)
          _menuItem(
            context,
            value: 'convert',
            icon: Icons.receipt_long_rounded,
            label: 'Convert to Invoice',
            color: AppColors.primary,
          ),
        _menuItem(
          context,
          value: 'print',
          icon: Icons.print_rounded,
          label: 'Print',
          color: context.colors.textSecondary,
        ),
        _menuItem(
          context,
          value: 'delete',
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          color: AppColors.error,
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
    BuildContext context, {
    required String value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: Dimensions.iconSize16 + 4, color: color),
          SizedBox(width: Dimensions.width10),
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              fontWeight: FontWeight.w600,
              color: value == 'delete'
                  ? AppColors.error
                  : context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Quote',
      message:
          'Are you sure you want to delete ${quote.quoteNumber}? This action cannot be undone.',
    );
    if (confirmed && context.mounted) {
      widget.onDelete?.call();
      Navigator.pop(context);
    }
  }

  Widget _buildHeader(BuildContext context) {
    final statusColor = quote.status.color;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: Dimensions.radius15 * 0.53,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quote Date',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.7,
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10 + 2,
                  vertical: Dimensions.height10 * 0.5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Dimensions.radius30),
                ),
                child: Text(
                  quote.status.label,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.62,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height10 / 2.5),
          Text(
            quote.quoteDateLabel.isNotEmpty
                ? quote.quoteDateLabel
                : DateFormat('dd MMM yyyy').format(quote.quoteDate),
            style: TextStyle(
              fontSize: Dimensions.font20 * 0.95,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: Dimensions.height20),
          Text(
            quote.customerName,
            style: TextStyle(
              fontSize: Dimensions.font20 * 0.95,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: Dimensions.height10 / 2.5),
          Text(
            quote.quoteNumber,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
            ),
          ),
          if (quote.subject.isNotEmpty) ...[
            SizedBox(height: Dimensions.height10 / 2.5),
            Text(
              quote.subject,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.8,
                color: context.colors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return _cardWrapper(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'QUOTE INFORMATION'),
          SizedBox(height: Dimensions.height15),
          if (quote.referenceNumber.isNotEmpty) ...[
            DetailRow(
              label: 'Reference#:',
              value: quote.referenceNumber,
            ),
            SizedBox(height: Dimensions.height15),
          ],
          if (quote.expiryDate != null) ...[
            DetailRow(
              label: 'Expiry Date:',
              value: quote.expiryDateLabel.isNotEmpty
                  ? quote.expiryDateLabel
                  : DateFormat('dd MMM yyyy').format(quote.expiryDate!),
            ),
            SizedBox(height: Dimensions.height15),
          ],
          DetailRow(
            label: 'Tax Type:',
            value: quote.taxInclusive ? 'Tax Inclusive' : 'Tax Exclusive',
          ),
          if (quote.salesperson.isNotEmpty) ...[
            SizedBox(height: Dimensions.height15),
            DetailRow(label: 'Salesperson:', value: quote.salesperson),
          ],
          if (quote.projectName.isNotEmpty) ...[
            SizedBox(height: Dimensions.height15),
            DetailRow(label: 'Project:', value: quote.projectName),
          ],
        ],
      ),
    );
  }

  Widget _buildLineItemsCard(BuildContext context) {
    return _cardWrapper(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'ITEMS'),
          SizedBox(height: Dimensions.height15),
          if (quote.lineItems.isEmpty)
            Text(
              'No items added.',
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.85,
                color: context.colors.textTertiary,
              ),
            )
          else
            ...List.generate(quote.lineItems.length, (i) {
              final line = quote.lineItems[i];
              return Padding(
                padding: EdgeInsets.only(
                  bottom:
                      i == quote.lineItems.length - 1 ? 0 : Dimensions.height15,
                ),
                child: _buildLineItemRow(context, line),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLineItemRow(BuildContext context, QuoteLineItem line) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.itemName,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.9,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              if (line.description.isNotEmpty) ...[
                SizedBox(height: Dimensions.height10 / 3),
                Text(
                  line.description,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.75,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
              SizedBox(height: Dimensions.height10 / 2),
              Text(
                '${_qtyText(line.quantity)} × ${_currency.format(line.rate)}'
                '${line.discount > 0 ? '  •  -${line.discountIsPercent ? '${_qtyText(line.discount)}%' : _currency.format(line.discount)}' : ''}'
                '${line.taxRate > 0 ? '  •  ${_qtyText(line.taxRate)}% tax' : ''}',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.75,
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: Dimensions.width10),
        Text(
          // Prefer the API-returned amount field when available.
          line.amount > 0
              ? _currency.format(line.amount)
              : _currency.format(line.quantity * line.rate),
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.9,
            fontWeight: FontWeight.w800,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsCard(BuildContext context) {
    return _cardWrapper(
      context,
      Column(
        children: [
          _totalRow(
            context,
            'Sub Total',
            _currency.format(quote.subTotal > 0 ? quote.subTotal : quote.totalAmount),
          ),
          SizedBox(height: Dimensions.height10),
          _totalRow(context, 'Tax', _currency.format(quote.taxAmountComputed)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
            child: Divider(height: 1, color: context.colors.border),
          ),
          _totalRow(
            context,
            'Total',
            _currency.format(quote.totalAmount),
            emphasize: true,
          ),
        ],
      ),
    );
  }

  Widget _totalRow(
    BuildContext context,
    String label,
    String value, {
    bool emphasize = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize:
                emphasize ? Dimensions.font16 : Dimensions.font16 * 0.85,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
            color: emphasize
                ? context.colors.textPrimary
                : context.colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize:
                emphasize ? Dimensions.font20 * 0.95 : Dimensions.font16,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
            color:
                emphasize ? AppColors.primary : context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(BuildContext context, String title, String body) {
    return _cardWrapper(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, title.toUpperCase()),
          SizedBox(height: Dimensions.height10),
          Text(
            body,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              height: 1.5,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardWrapper(BuildContext context, Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: Dimensions.radius15 * 0.53,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Dimensions.font16 * 0.7,
        fontWeight: FontWeight.w700,
        color: context.colors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }

  String _qtyText(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';
}