import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:flutter/material.dart';

class CommentsTab extends StatefulWidget {
  const CommentsTab({super.key});

  @override
  State<CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<CommentsTab> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              'No comments yet.',
              style: TextStyle(
                fontSize: Dimensions.font16,
                color: context.colors.textTertiary,
              ),
            ),
          ),
        ),

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
                      borderSide: BorderSide(
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
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: Dimensions.iconSize24 * 0.9,
                  ),
                  onPressed: () {
                    if (_commentController.text.trim().isNotEmpty) {
                      appLog(
                        '💬 Comment sent: ${_commentController.text}',
                        name: 'CommentsTab',
                      );
                      _commentController.clear();
                      FocusScope.of(context).unfocus();
                      ToastificationHelper.showSuccess(
                        context,
                        'Comment added.',
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
