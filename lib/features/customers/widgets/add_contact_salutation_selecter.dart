import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:flutter/material.dart';

class AddContactSalutationSelecter extends StatelessWidget {
  final String selectedSalutation;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const AddContactSalutationSelecter({
    super.key,
    required this.selectedSalutation,
    required this.options,
    required this.onSelected,
  });

  void _showSalutationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height15,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: context.colors.border, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Salutation',
                      style: TextStyle(
                        fontSize: Dimensions.font20 * 0.85,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(sheetContext),
                      child: Icon(
                        Icons.close_rounded,
                        size: Dimensions.iconSize24,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(Dimensions.width20),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = selectedSalutation == option;

                  return GestureDetector(
                    onTap: () {
                      onSelected(option);

                      Navigator.pop(sheetContext);

                      appLog(
                        '✅ Salutation selected: $option',
                        name: 'SalutationSelector',
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: Dimensions.height10),
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width15,
                        vertical: Dimensions.height15,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius15,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : context.colors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option,
                            style: TextStyle(
                              fontSize: Dimensions.font16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : context.colors.textPrimary,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: Dimensions.iconSize24,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: Dimensions.height10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = selectedSalutation.isEmpty;

    return GestureDetector(
      onTap: () => _showSalutationSheet(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width15,
          vertical: Dimensions.height15,
        ),
        decoration: BoxDecoration(
          color: context.colors.surfaceLight,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
            color: isEmpty ? context.colors.border : AppColors.primary,
            width: isEmpty ? 1 : 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                isEmpty ? 'Salutation' : selectedSalutation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.85,
                  color: isEmpty
                      ? context.colors.textTertiary
                      : context.colors.textPrimary,
                  fontWeight: isEmpty ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: Dimensions.iconSize16 * 1.2,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
