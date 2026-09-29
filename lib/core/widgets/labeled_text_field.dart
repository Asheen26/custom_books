import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:flutter/material.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final bool hasInfo;
  final String? placeholder;
  final IconData? suffixIcon;

  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.hasInfo = false,
    this.placeholder,
    this.suffixIcon,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.85,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (isRequired) ...[
                SizedBox(width: Dimensions.width10 / 3),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.85,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
              if (hasInfo) ...[
                SizedBox(width: Dimensions.width10 / 2),
                Icon(
                  Icons.info_outline,
                  size: Dimensions.iconSize16,
                  color: context.colors.textTertiary,
                ),
              ],
            ],
          ),
          SizedBox(height: Dimensions.height10),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.85,
            color: context.colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: context.colors.textTertiary,
              fontSize: Dimensions.font16 * 0.85,
            ),
            errorText: errorText,
            errorStyle: TextStyle(
              fontSize: Dimensions.font16 * 0.75,
              color: AppColors.error,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: context.colors.textSecondary)
                : null,
            filled: true,
            fillColor: context.colors.surfaceLight,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.width15,
              vertical: Dimensions.height15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              borderSide: BorderSide(color: context.colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              borderSide: BorderSide(color: context.colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
