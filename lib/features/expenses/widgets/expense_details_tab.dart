import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/features/expenses/models/expense_model.dart';
import 'package:flutter/material.dart';

/// DETAILS tab for [ExpenseDetailsPage].
class ExpenseDetailsTab extends StatelessWidget {
  final ExpenseModel expense;
  const ExpenseDetailsTab({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: EdgeInsets.all(Dimensions.width20),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(Dimensions.radius15),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailRow(
                label: 'Vendor:',
                value: expense.vendorName.isEmpty ? '—' : expense.vendorName,
              ),
              SizedBox(height: Dimensions.height15),
              DetailRow(
                label: 'Reference#:',
                value: expense.referenceNumber.isEmpty
                    ? '—'
                    : expense.referenceNumber,
              ),
              SizedBox(height: Dimensions.height15),
              DetailRow(
                label: 'Amount:',
                value: '₹${expense.amount.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.height30),
      ],
    );
  }
}
