import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:flutter/material.dart';

class MoreInformationSection extends StatefulWidget {
  const MoreInformationSection({super.key});

  @override
  State<MoreInformationSection> createState() => _MoreInformationSectionState();
}

class _MoreInformationSectionState extends State<MoreInformationSection> {
  bool _isMoreInfoExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        Dimensions.width20,
        Dimensions.height15,
        Dimensions.width20,
        0,
      ),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isMoreInfoExpanded = !_isMoreInfoExpanded;
                });
                appLog(
                  'ℹ️ More Information section tapped: ${_isMoreInfoExpanded ? "expanded" : "collapsed"}',
                  name: 'MoreInformationSection',
                );
              },
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              child: Padding(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Row(
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: Dimensions.iconSize24,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: Dimensions.width15),
                    Expanded(
                      child: Text(
                        'More Information',
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _isMoreInfoExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: Dimensions.iconSize24,
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isMoreInfoExpanded) ...[
            Divider(height: 1, color: context.colors.border),
            Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: Dimensions.height10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payment Terms",
                          style: TextStyle(
                            fontSize: Dimensions.font16 * 0.8,
                            color: context.colors.textTertiary,
                          ),
                        ),
                        SizedBox(height: Dimensions.height10 / 3),
                        Text(
                          "Due on Receipt",
                          style: TextStyle(
                            fontSize: Dimensions.font16 * 0.9,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
