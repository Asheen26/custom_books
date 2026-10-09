import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/features/banking/models/bank_transaction.dart';
import 'package:flutter/material.dart';

/// DETAILS tab for [BankTransactionDetailsPage].
class BankTxnDetailsTab extends StatelessWidget {
  final BankTransaction transaction;
  final String accountName;
  const BankTxnDetailsTab({super.key, required this.transaction, required this.accountName});

  @override
  Widget build(BuildContext context) {
    final txn = transaction;
    final hasInvoice = txn.invoiceNumber != null && txn.invoiceNumber!.isNotEmpty;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        if (hasInvoice) ...[
          _card(context, Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Invoice Details', style: _labelStyle(context)),
                  Text('Payment Amount', style: _labelStyle(context)),
                ],
              ),
              SizedBox(height: Dimensions.height10),
              Divider(height: 1, color: context.colors.border),
              SizedBox(height: Dimensions.height15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(txn.invoiceNumber!, style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  Text('${txn.currency}${txn.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
                ],
              ),
              if (txn.invoiceDate != null) ...[
                SizedBox(height: Dimensions.height10),
                DetailRow(label: 'Invoice Date:', value: formatDate(txn.invoiceDate!)),
              ],
              if (txn.invoiceAmount != null) ...[
                SizedBox(height: Dimensions.height10),
                DetailRow(label: 'Invoice Amount:', value: '${txn.currency}${txn.invoiceAmount!.toStringAsFixed(2)}'),
              ],
            ],
          )),
          SizedBox(height: Dimensions.height15),
        ] else ...[
          _card(context, Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transaction Details', style: _titleStyle(context)),
              SizedBox(height: Dimensions.height15),
              DetailRow(label: 'Type:', value: txn.type),
              SizedBox(height: Dimensions.height15),
              DetailRow(label: 'Amount:', value: '${txn.currency}${txn.amount.toStringAsFixed(2)}'),
              SizedBox(height: Dimensions.height15),
              DetailRow(label: 'Date:', value: formatDate(txn.date)),
              SizedBox(height: Dimensions.height15),
              DetailRow(label: 'Source:', value: txn.source),
            ],
          )),
          SizedBox(height: Dimensions.height15),
        ],

        _card(context, Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('More Information', style: _titleStyle(context)),
            SizedBox(height: Dimensions.height15),
            _infoBlock(context, 'Deposit To', txn.depositTo?.isNotEmpty == true ? txn.depositTo! : accountName),
            SizedBox(height: Dimensions.height15),
            _infoBlock(context, 'Notes', txn.notes?.isNotEmpty == true ? txn.notes! : 'No notes provided.'),
          ],
        )),

        if (txn.template != null && txn.template!.isNotEmpty) ...[
          SizedBox(height: Dimensions.height15),
          _card(context, Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Template', style: TextStyle(fontSize: Dimensions.font16 * 0.72, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
              SizedBox(height: Dimensions.height10 / 2),
              Row(
                children: [
                  Text("'${txn.template}'", style: TextStyle(fontSize: Dimensions.font16 * 0.88, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                  Text(' - ', style: TextStyle(fontSize: Dimensions.font16 * 0.88, color: context.colors.textSecondary)),
                  GestureDetector(
                    onTap: () => ToastificationHelper.showInfo(context, 'Changing template is coming soon.'),
                    child: Text('Change', style: TextStyle(fontSize: Dimensions.font16 * 0.88, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
            ],
          )),
        ],
        SizedBox(height: Dimensions.height30),
      ],
    );
  }

  Widget _card(BuildContext context, Widget child) => Container(
    padding: EdgeInsets.all(Dimensions.width20),
    decoration: BoxDecoration(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: child,
  );

  Widget _infoBlock(BuildContext context, String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: Dimensions.font16 * 0.72, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
      SizedBox(height: Dimensions.height10 / 2),
      Text(value, style: TextStyle(fontSize: Dimensions.font16 * 0.85, color: context.colors.textPrimary, fontWeight: FontWeight.w600, height: 1.4)),
    ],
  );

  TextStyle _titleStyle(BuildContext context) => TextStyle(fontSize: Dimensions.font16 * 0.95, fontWeight: FontWeight.w800, color: context.colors.textPrimary);
  TextStyle _labelStyle(BuildContext context) => TextStyle(fontSize: Dimensions.font16 * 0.78, fontWeight: FontWeight.w600, color: context.colors.textSecondary);
}
