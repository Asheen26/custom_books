import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:flutter/material.dart';

/// A simple comment entry that lives only in memory for this session.
class _CommentEntry {
  _CommentEntry({
    required this.text,
    required this.timestamp,
    this.author = 'trial01@gmail.com',
  });
  final String text;
  final DateTime timestamp;
  final String author;
}

class CommentsTab extends StatefulWidget {
  const CommentsTab({super.key});

  @override
  State<CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<CommentsTab> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_CommentEntry> _comments = [];

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    appLog('💬 Comment sent: $text', name: 'CommentsTab');

    setState(() {
      _comments.add(_CommentEntry(text: text, timestamp: DateTime.now()));
    });

    _commentController.clear();
    FocusScope.of(context).unfocus();

    // Scroll to the bottom after the frame renders the new item.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _comments.isEmpty
              ? Center(
                  child: Text(
                    'No comments yet.',
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      color: context.colors.textTertiary,
                    ),
                  ),
                )
              : ListView.separated(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height15,
                  ),
                  itemCount: _comments.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: Dimensions.height10),
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    return _CommentBubble(comment: comment);
                  },
                ),
        ),

        // ── Input bar ──────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.all(Dimensions.width20),
          decoration: BoxDecoration(
            color: context.colors.card,
            border: Border(
              top: BorderSide(color: context.colors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                  decoration: InputDecoration(
                    hintText: 'Type to add a comment',
                    hintStyle: TextStyle(
                      color: context.colors.textTertiary,
                      fontSize: Dimensions.font16 * 0.85,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                      borderSide: BorderSide(color: context.colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                      borderSide: BorderSide(color: context.colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height15,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Dimensions.width10),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: Dimensions.iconSize24 * 0.9,
                  ),
                  onPressed: _submitComment,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Comment row (feed style) ───────────────────────────────────────────────

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({required this.comment});
  final _CommentEntry comment;

  /// "25 Sep 2026, 09:26 AM"
  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final mon = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$day $mon $year, ${hour.toString().padLeft(2, '0')}:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height15,
      ),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15 * 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Square icon ──────────────────────────────────────────────
          Container(
            width: Dimensions.height45 * 0.85,
            height: Dimensions.height45 * 0.85,
            decoration: BoxDecoration(
              color: context.colors.surfaceLight,
              borderRadius: BorderRadius.circular(Dimensions.radius15 / 3),
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(
              Icons.comment_outlined,
              size: Dimensions.iconSize20 * 0.85,
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(width: Dimensions.width20 * 0.7),

          // ── Text column ───────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.text,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.9,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: Dimensions.height10 / 2.5),
                Row(
                  children: [
                    Text(
                      comment.author,
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.7,
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width10 / 2.5,
                      ),
                      child: Text(
                        '•',
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.7,
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ),
                    Text(
                      _formatDateTime(comment.timestamp),
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.7,
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w400,
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
}
