import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/features/invoices/controllers/invoice_comments_controller.dart';
import 'package:custom_books/features/invoices/models/invoice_comment_model.dart';
import 'package:custom_books/features/invoices/models/invoice_model.dart';
import 'package:flutter/material.dart';

class InvoiceDetailsTabView extends StatefulWidget {
  final InvoiceModel invoice;
  final TabController tabController;

  const InvoiceDetailsTabView({
    super.key,
    required this.invoice,
    required this.tabController,
  });

  @override
  State<InvoiceDetailsTabView> createState() => _InvoiceDetailsTabViewState();
}

class _InvoiceDetailsTabViewState extends State<InvoiceDetailsTabView> {
  late final InvoiceCommentsController _commentsController =
      InvoiceCommentsController(widget.invoice.id);
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentsController.addListener(_onChanged);
    _commentsController.load();
  }

  @override
  void dispose() {
    _commentsController.removeListener(_onChanged);
    _commentsController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _submitComment() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    final ok = await _commentsController.submit(text);
    if (!mounted) return;
    if (ok) {
      _inputController.clear();
    } else if (_commentsController.errorMessage != null) {
      ToastificationHelper.showError(
        context,
        _commentsController.errorMessage!,
      );
    }
  }

  // ── Details tab ───────────────────────────────────────────────────────────
  Widget _buildDetailsTab() {
    final invoice = widget.invoice;
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailRow(label: 'Due Date:', value: formatDate(invoice.dueDate)),
              SizedBox(height: Dimensions.height15),
              DetailRow(
                label: 'Terms:',
                value: invoice.terms.isEmpty ? '-' : invoice.terms,
              ),
              SizedBox(height: Dimensions.height15),
              DetailRow(
                label: 'Place of Supply:',
                value: invoice.placeOfSupply.isEmpty
                    ? '-'
                    : invoice.placeOfSupply,
              ),
              SizedBox(height: Dimensions.height15),
              DetailRow(
                label: 'Sub Total:',
                value: '₹${invoice.subTotal.toStringAsFixed(2)}',
              ),
              SizedBox(height: Dimensions.height15),
              DetailRow(
                label: 'Tax:',
                value: '₹${invoice.taxAmount.toStringAsFixed(2)}',
              ),
              SizedBox(height: Dimensions.height15),
              DetailRow(
                label: 'Total:',
                value: '₹${invoice.total.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.height30),
      ],
    );
  }

  // ── Comments & History tab ────────────────────────────────────────────────
  Widget _buildCommentsTab() {
    return Column(
      children: [
        Expanded(child: _buildCommentsList()),
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentsList() {
    final comments = _commentsController.comments;

    if (_commentsController.isLoading && comments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      );
    }

    if (comments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Dimensions.width20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(Dimensions.width20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: Dimensions.iconSize24 * 2,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: Dimensions.height20),
              Text(
                'No comments or history yet',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.95,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                'Add a comment below to start the\nactivity history',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.8,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      itemCount: comments.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: Dimensions.height10),
      itemBuilder: (_, i) => _buildCommentTile(comments[i]),
    );
  }

  Widget _buildCommentTile(InvoiceComment comment) {
    final accent = comment.isSystem ? AppColors.accent : AppColors.primary;
    return Container(
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: Dimensions.height45 * 0.8,
            height: Dimensions.height45 * 0.8,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              comment.isSystem
                  ? Icons.history_rounded
                  : Icons.chat_bubble_outline_rounded,
              size: Dimensions.iconSize24 - 6,
              color: accent,
            ),
          ),
          SizedBox(width: Dimensions.width15),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.text,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.85,
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: Dimensions.height10 / 2),
                Row(
                  children: [
                    if (comment.author.isNotEmpty) ...[
                      Flexible(
                        child: Text(
                          comment.author,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Dimensions.font16 * 0.7,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                      if (comment.createdAt != null)
                        Text(
                          '  •  ',
                          style: TextStyle(
                            fontSize: Dimensions.font16 * 0.7,
                            color: context.colors.textTertiary,
                          ),
                        ),
                    ],
                    if (comment.createdAt != null)
                      Text(
                        formatDateTime(comment.createdAt!),
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.7,
                          color: context.colors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.width20,
        Dimensions.height10,
        Dimensions.width20,
        Dimensions.height15,
      ),
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15,
                  vertical: Dimensions.height10 / 2,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceLight,
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                  border: Border.all(color: context.colors.border),
                ),
                child: TextField(
                  controller: _inputController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.85,
                    color: context.colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a comment',
                    hintStyle: TextStyle(color: context.colors.textTertiary),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
            SizedBox(width: Dimensions.width10),
            // Send button
            AnimatedBuilder(
              animation: _commentsController,
              builder: (context, _) {
                final busy = _commentsController.isSubmitting;
                return InkWell(
                  onTap: busy ? null : _submitComment,
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                  child: Container(
                    width: Dimensions.height45,
                    height: Dimensions.height45,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: busy
                        ? Padding(
                            padding: EdgeInsets.all(Dimensions.width10),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: [_buildDetailsTab(), _buildCommentsTab()],
    );
  }
}
