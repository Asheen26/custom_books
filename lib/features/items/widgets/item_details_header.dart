import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/image_helper.dart';
import 'package:custom_books/features/items/models/item_model.dart';
import 'package:flutter/material.dart';

/// Summary header shown at the top of [ItemDetailsPage]:
/// item name, selling price, purchase cost, and item image.
class ItemDetailsHeader extends StatelessWidget {
  final ItemModel item;

  const ItemDetailsHeader({super.key, required this.item});

  String _money(double value) => 'AED${value.toStringAsFixed(2)}';

  String get _unitSuffix =>
      (item.unit != null && item.unit!.isNotEmpty) ? ' per ${item.unit}' : '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: Dimensions.font20 * 1.1,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: Dimensions.height15),
                _priceBlock(context, 'Selling Price', item.salesPrice),
                SizedBox(height: Dimensions.height10),
                _priceBlock(context, 'Purchase Cost', item.purchasePrice),
              ],
            ),
          ),
          SizedBox(width: Dimensions.width15),
          Container(
            width: Dimensions.height45 * 2,
            height: Dimensions.height45 * 2,
            decoration: BoxDecoration(
              color: context.colors.surfaceLight,
              borderRadius: BorderRadius.circular(Dimensions.radius15),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imageUrl != null
                ? ImageHelper.buildImage(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: _placeholder(context),
                  )
                : _placeholder(context),
          ),
        ],
      ),
    );
  }

  Widget _priceBlock(BuildContext context, String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.78,
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: Dimensions.height10 / 4),
        RichText(
          text: TextSpan(
            text: _money(value),
            style: TextStyle(
              fontSize: Dimensions.font20 * 0.95,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
            children: [
              if (_unitSuffix.isNotEmpty)
                TextSpan(
                  text: _unitSuffix,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.85,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) => Icon(
    Icons.image_outlined,
    size: Dimensions.iconSize24 * 1.6,
    color: context.colors.textTertiary,
  );
}
