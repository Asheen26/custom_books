import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:custom_books/features/customers/views/customer_details_page.dart';
import 'package:flutter/material.dart';

class CustomerCardWidget extends StatelessWidget {
  final CustomerModel customer;

  const CustomerCardWidget({super.key, required this.customer});

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF64B5F6),
      const Color(0xFF81C784),
      const Color(0xFFFFB74D),
      const Color(0xFFE57373),
      const Color(0xFF9575CD),
      const Color(0xFF4DD0E1),
    ];

    final index = name.length % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailsPage(customer: customer),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(Dimensions.width20),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: Dimensions.height45 * 1.1,
              height: Dimensions.height45 * 1.1,
              decoration: BoxDecoration(
                color: _getAvatarColor(customer.name),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  customer.initials,
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(width: Dimensions.width15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.95,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (customer.email != null) ...[
                    SizedBox(height: Dimensions.height10 / 2),
                    Text(
                      customer.email!,
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.75,
                        color: context.colors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  SizedBox(height: Dimensions.height15),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Receivables',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.7,
                                color: context.colors.textTertiary,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10 / 3),
                            Text(
                              '₹${customer.receivables.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.85,
                                fontWeight: FontWeight.w700,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unused Credits',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.7,
                                color: context.colors.textTertiary,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10 / 3),
                            Text(
                              '₹${customer.unusedCredits.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.85,
                                fontWeight: FontWeight.w700,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
