import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:flutter/material.dart';

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(Dimensions.width20),
          decoration: BoxDecoration(
            color: context.colors.card,
            border: Border(
              bottom: BorderSide(color: context.colors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width15,
                    vertical: Dimensions.height10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.border),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radius15 / 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Invoice',
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.85,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: Dimensions.iconSize24,
                        color: context.colors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: Dimensions.width10),
              IconButton(
                icon: Icon(
                  Icons.filter_list_rounded,
                  size: Dimensions.iconSize24,
                  color: context.colors.textSecondary,
                ),
                onPressed: () {
                  appLog('🔍 Filter button pressed', name: 'TransactionsTab');
                  ToastificationHelper.showInfo(
                    context,
                    'There are no comments to filter yet.',
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.sort_rounded,
                  size: Dimensions.iconSize24,
                  color: context.colors.textSecondary,
                ),
                onPressed: () {
                  appLog('🔀 Sort button pressed', name: 'TransactionsTab');
                  ToastificationHelper.showInfo(
                    context,
                    'There are no comments to sort yet.',
                  );
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Dimensions.height45 * 3,
                height: Dimensions.height45 * 3,
                decoration: BoxDecoration(
                  color: context.colors.surfaceLight,
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                ),
                child: Center(
                  child: Icon(
                    Icons.description_outlined,
                    size: Dimensions.height45 * 1.5,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.height20),
              Text(
                'Total Count',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.8,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Dimensions.height30),
              Text(
                'No Invoices created so far.',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
