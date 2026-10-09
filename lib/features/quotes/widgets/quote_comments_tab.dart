import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuoteLocalComment {
  final String text;
  final DateTime createdAt;
  QuoteLocalComment({required this.text, required this.createdAt});
}

/// COMMENTS & HISTORY tab for [QuoteDetailsPage].
class QuoteCommentsTab extends StatelessWidget {
  final List<QuoteLocalComment> comments;
  final TextEditingController inputController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const QuoteCommentsTab({
    super.key,
    required this.comments,
    required this.inputController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildList(context)),
        _buildInput(context),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
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
      itemBuilder: (_, i) => _CommentTile(comment: comments[i]),
    );
  }

  Widget _buildInput(BuildContext context) {
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
                  controller: inputController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSubmit(),
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
            InkWell(
              onTap: isSubmitting ? null : onSubmit,
              borderRadius: BorderRadius.circular(Dimensions.radius20),
              child: Container(
                width: Dimensions.height45,
                height: Dimensions.height45,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: isSubmitting
                    ? Padding(
                        padding: EdgeInsets.all(Dimensions.width10),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: Dimensions.iconSize24 - 4,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final QuoteLocalComment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: Dimensions.height45 * 0.8,
            height: Dimensions.height45 * 0.8,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: Dimensions.iconSize24 - 6,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: Dimensions.width15),
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
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(comment.createdAt),
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.7,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
