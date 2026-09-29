import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:flutter/material.dart';

class CustomerCustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool isRequired;
  final bool hasInfo;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? prefix;

  const CustomerCustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.isRequired = false,
    this.hasInfo = false,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.prefix,
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
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.85,
            color: context.colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: context.colors.textTertiary,
              fontSize: Dimensions.font16 * 0.85,
            ),

            prefixText: prefix != null ? '$prefix ' : null,

            prefixStyle: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),

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
          ),
        ),
      ],
    );
  }
}
