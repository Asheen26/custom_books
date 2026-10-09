import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/features/delivery_challans/models/delivery_challan_model.dart';
import 'package:flutter/material.dart';

/// DETAILS tab for [DeliveryChallanDetailsPage].
class ChallanDetailsTab extends StatelessWidget {
  final DeliveryChallanModel challan;
  const ChallanDetailsTab({super.key, required this.challan});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        _card(context, [
          DetailRow(label: 'Challan#:', value: challan.challanNumber),
          SizedBox(height: Dimensions.height15),
          DetailRow(label: 'Reference#:', value: challan.referenceNumber.isEmpty ? '-' : challan.referenceNumber),
          SizedBox(height: Dimensions.height15),
          DetailRow(label: 'Type:', value: challan.type),
          SizedBox(height: Dimensions.height15),
          DetailRow(label: 'Amount:', value: '₹${challan.total.toStringAsFixed(2)}'),
        ]),
        if (challan.lineItems.isNotEmpty) ...[
          SizedBox(height: Dimensions.height15),
          _card(context, [
            Text('Line Items', style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
            SizedBox(height: Dimensions.height15),
            ...challan.lineItems.map((item) => Container(
              margin: EdgeInsets.only(bottom: Dimensions.height10),
              padding: EdgeInsets.all(Dimensions.width15),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(Dimensions.radius15),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.itemName, style: TextStyle(fontSize: Dimensions.font16 * 0.88, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                        if (item.description.isNotEmpty) ...[
                          SizedBox(height: Dimensions.height10 / 4),
                          Text(item.description, style: TextStyle(fontSize: Dimensions.font16 * 0.72, color: context.colors.textSecondary)),
                        ],
                        SizedBox(height: Dimensions.height10 / 2),
                        Text('${item.quantity.toStringAsFixed(2)} × ₹${item.rate.toStringAsFixed(2)}', style: TextStyle(fontSize: Dimensions.font16 * 0.72, color: context.colors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('₹${item.gross.toStringAsFixed(2)}', style: TextStyle(fontSize: Dimensions.font16 * 0.88, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                ],
              ),
            )),
            const Divider(),
            Padding(
              padding: EdgeInsets.only(top: Dimensions.height10 / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: TextStyle(fontSize: Dimensions.font16 * 0.9, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
                  Text('₹${challan.total.toStringAsFixed(2)}', style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
            ),
          ]),
        ],
        SizedBox(height: Dimensions.height30),
      ],
    );
  }

  Widget _card(BuildContext context, List<Widget> children) => Container(
    padding: EdgeInsets.all(Dimensions.width20),
    decoration: BoxDecoration(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}
