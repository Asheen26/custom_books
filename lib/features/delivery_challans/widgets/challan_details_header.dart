import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/delivery_challans/models/delivery_challan_model.dart';
import 'package:flutter/material.dart';

/// Summary header card for [DeliveryChallanDetailsPage].
class ChallanDetailsHeader extends StatelessWidget {
  final DeliveryChallanModel challan;
  const ChallanDetailsHeader({super.key, required this.challan});

  @override
  Widget build(BuildContext context) {
    final statusColor = challan.status.color;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.card,
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date', style: TextStyle(fontSize: Dimensions.font16 * 0.7, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width10 + 2, vertical: Dimensions.height10 * 0.5),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(Dimensions.radius30)),
                child: Text(challan.status.label, style: TextStyle(fontSize: Dimensions.font16 * 0.62, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: statusColor)),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height10 / 2.5),
          Text(formatDate(challan.challanDate), style: TextStyle(fontSize: Dimensions.font20 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
          SizedBox(height: Dimensions.height20),
          Text(challan.customerName, style: TextStyle(fontSize: Dimensions.font20 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
          SizedBox(height: Dimensions.height10 / 2.5),
          Text(challan.challanNumber, style: TextStyle(fontSize: Dimensions.font16 * 0.85, color: context.colors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
