import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/quotes/models/quote_model.dart';
import 'package:custom_books/features/quotes/viewmodels/quotes_list_viewmodel.dart';
import 'package:custom_books/features/quotes/views/add_quote_page.dart';
import 'package:custom_books/features/quotes/widgets/quote_comments_tab.dart';
import 'package:custom_books/features/quotes/widgets/quote_details_header.dart';
import 'package:custom_books/features/quotes/widgets/quote_details_tab.dart';
import 'package:flutter/material.dart';

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

class _QuoteDetailsPageState extends State<QuoteDetailsPage>
    with SingleTickerProviderStateMixin {
  final _vm = QuotesListViewModel();
  late TabController _tabController;
  final TextEditingController _commentInputController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmittingComment = false;
  String? _errorMessage;
  final List<QuoteLocalComment> _comments = [];

  late QuoteModel _quote;
  QuoteModel get quote => _quote;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _quote = widget.quote;
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentInputController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final resp = await _vm.fetchQuoteDetail(widget.quote.id);
    if (!mounted) return;
    final int? statusCode = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        statusCode != null &&
        statusCode >= 200 &&
        statusCode < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) {
        setState(() => _quote = QuoteModel.fromJson(data));
        appLog(
          'Quote detail loaded: ${_quote.quoteNumber}',
          name: 'QuoteDetailsPage',
        );
      }
    } else {
      final msg = (resp?['message'] ?? 'Failed to load quote details.')
          .toString();
      setState(() => _errorMessage = msg);
      appLog('Quote detail fetch failed: $msg', name: 'QuoteDetailsPage');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _submitComment() async {
    final text = _commentInputController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmittingComment = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _comments.insert(
        0,
        QuoteLocalComment(text: text, createdAt: DateTime.now()),
      );
      _commentInputController.clear();
      _isSubmittingComment = false;
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Quote',
      message:
          'Are you sure you want to delete ${quote.quoteNumber}? This action cannot be undone.',
    );
    if (confirmed && mounted) {
      widget.onDelete?.call();
      Navigator.pop(context);
    }
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
            onPressed: () async {
              final updated = await Navigator.push<QuoteModel?>(
                context,
                MaterialPageRoute(builder: (_) => AddQuotePage(quote: quote)),
              );
              if (updated != null && context.mounted) {
                widget.onStatusChanged?.call(updated.status);
                Navigator.pop(context);
              }
            },
          ),
          _actionsMenu(),
          SizedBox(width: Dimensions.width10),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const DetailsPageSkeleton(showTabs: true, showLineItems: true)
            : Column(
                children: [
                  QuoteDetailsHeader(quote: quote),
                  SizedBox(height: Dimensions.height15),
                  _pillTabBar(),
                  SizedBox(height: Dimensions.height15),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        QuoteDetailsTab(
                          quote: quote,
                          errorMessage: _errorMessage,
                          onRetry: _load,
                        ),
                        QuoteCommentsTab(
                          comments: _comments,
                          inputController: _commentInputController,
                          isSubmitting: _isSubmittingComment,
                          onSubmit: _submitComment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _pillTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.surfaceLight,
        borderRadius: BorderRadius.circular(Dimensions.radius30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
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
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.primary,
        unselectedLabelColor: context.colors.textSecondary,
        labelStyle: TextStyle(
          fontSize: Dimensions.font16 * 0.72,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
        dividerColor: Colors.transparent,
        padding: EdgeInsets.all(Dimensions.width10 / 2),
        tabs: const [
          Tab(text: 'DETAILS'),
          Tab(text: 'COMMENTS & HISTORY'),
        ],
      ),
    );
  }

  Widget _actionsMenu() {
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
            _confirmDelete();
        }
      },
      itemBuilder: (context) => [
        if (quote.status == QuoteStatus.draft)
          _mi(
            context,
            'mark_sent',
            Icons.send_outlined,
            'Mark as Sent',
            AppColors.primaryLight,
          ),
        if (quote.status == QuoteStatus.sent) ...[
          _mi(
            context,
            'mark_accepted',
            Icons.check_circle_outline_rounded,
            'Mark as Accepted',
            AppColors.success,
          ),
          _mi(
            context,
            'mark_declined',
            Icons.cancel_outlined,
            'Mark as Declined',
            AppColors.error,
          ),
        ],
        if (quote.status == QuoteStatus.accepted)
          _mi(
            context,
            'convert',
            Icons.receipt_long_rounded,
            'Convert to Invoice',
            AppColors.primary,
          ),
        _mi(
          context,
          'print',
          Icons.print_rounded,
          'Print',
          context.colors.textSecondary,
        ),
        _mi(
          context,
          'delete',
          Icons.delete_outline_rounded,
          'Delete',
          AppColors.error,
        ),
      ],
    );
  }

  PopupMenuItem<String> _mi(
    BuildContext ctx,
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
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
                  : ctx.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
