import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:flutter/material.dart';

class SalutationSelector extends StatelessWidget {
  final String selectedSalutation;
  final ValueChanged<String> onChanged;

  const SalutationSelector({
    super.key,
    required this.selectedSalutation,
    required this.onChanged,
  });

  static const List<String> _salutationOptions = [
    'Mr.',
    'Mrs.',
    'Ms.',
    'Miss.',
    'Dr.',
  ];

  void _showSalutationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20),
        ),
      ),
      builder: (_) {
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
                      onTap: () => Navigator.pop(context),
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
                itemCount: _salutationOptions.length,
                itemBuilder: (context, index) {
                  final option = _salutationOptions[index];
                  final isSelected = selectedSalutation == option;

                  return GestureDetector(
                    onTap: () {
                      onChanged(option);

                      appLog(
                        '✅ Salutation selected: $option',
                        name: 'SalutationSelector',
                      );

                      Navigator.pop(context);
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
            color: selectedSalutation.isEmpty
                ? context.colors.border
                : AppColors.primary,
            width: selectedSalutation.isEmpty ? 1 : 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                selectedSalutation.isEmpty ? 'Select' : selectedSalutation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.85,
                  color: selectedSalutation.isEmpty
                      ? context.colors.textTertiary
                      : context.colors.textPrimary,
                  fontWeight: selectedSalutation.isEmpty
                      ? FontWeight.w500
                      : FontWeight.w600,
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
