import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/features/purchase_orders/models/purchase_order_model.dart';
import 'package:flutter/material.dart';

/// Full-screen page for composing and sending a purchase-order email.
class PoEmailPage extends StatefulWidget {
  final PurchaseOrderModel order;

  const PoEmailPage({super.key, required this.order});

  @override
  State<PoEmailPage> createState() => _PoEmailPageState();
}

class _PoEmailPageState extends State<PoEmailPage> {
  final _ccController = TextEditingController();
  final _bccController = TextEditingController();
  bool _attachPdf = true;

  static const String _fromEmail = 'user1@demo1.techgeum.com';

  String get _subject =>
      'Purchase Order from demo1techgeum '
      '(Purchase Order #: ${widget.order.purchaseOrderNumber})';

  String get _body =>
      'Dear ${widget.order.vendorName},\n\n'
      'The purchase order (${widget.order.purchaseOrderNumber}) is attached '
      'with this email.\n\n'
      'An overview of the purchase order is available below:\n\n'
      '─────────────────────────────────────────\n\n'
      'Purchase Order # : ${widget.order.purchaseOrderNumber}\n\n'
      '─────────────────────────────────────────\n'
      'Order Date  :  ${formatDate(widget.order.orderDate)}\n'
      'Amount      :  ₹${widget.order.total.toStringAsFixed(2)} (in INR)\n'
      '─────────────────────────────────────────\n\n'
      'Please go through it and confirm the order. '
      'We look forward to working with you again.\n\n'
      'Regards,\nuser1\ndemo1techgeum';

  @override
  void dispose() {
    _ccController.dispose();
    _bccController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomBackAppBar(
        title: 'Email Purchase Order',
        backgroundColor: context.colors.card,
        actions: [
          IconButton(
            icon: Icon(
              Icons.attach_file_rounded,
              color: context.colors.textSecondary,
            ),
            onPressed: () => ToastificationHelper.showInfo(
              context,
              'Attach file coming soon.',
            ),
          ),
          IconButton(
            icon: Icon(Icons.send_rounded, color: AppColors.primary),
            onPressed: () {
              ToastificationHelper.showSuccess(
                context,
                'Email sent successfully.',
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // From
          _row(
            context,
            label: 'From',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _fromEmail,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.88,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
          _divider(context),

          // To
          _row(
            context,
            label: 'To',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '0 contact selected',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.88,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
          _divider(context),

          // Cc
          _row(
            context,
            label: 'Cc',
            child: TextField(
              controller: _ccController,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.88,
                color: context.colors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(color: context.colors.textTertiary),
              ),
            ),
          ),
          _divider(context),

          // Bcc
          _row(
            context,
            label: 'Bcc',
            child: TextField(
              controller: _bccController,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.88,
                color: context.colors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(color: context.colors.textTertiary),
              ),
            ),
          ),
          _divider(context),

          // Subject
          _row(
            context,
            label: 'Subject',
            child: Text(
              _subject,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.88,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          _divider(context),

          // Body preview
          Container(
            margin: EdgeInsets.all(Dimensions.width15),
            padding: EdgeInsets.all(Dimensions.width20),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              border: Border.all(color: context.colors.border),
            ),
            child: Text(
              _body,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.82,
                color: context.colors.textPrimary,
                height: 1.55,
              ),
            ),
          ),

          // Attach PDF toggle
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height10,
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _attachPdf,
                  onChanged: (v) => setState(() => _attachPdf = v ?? true),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: Dimensions.width10 / 2),
                Text(
                  'Attach Purchase Order PDF',
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.88,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // PDF chip
          if (_attachPdf)
            Padding(
              padding: EdgeInsets.fromLTRB(
                Dimensions.width20,
                0,
                Dimensions.width20,
                Dimensions.height20,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Dimensions.width10 / 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radius15 / 3,
                      ),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.red.shade600,
                      size: Dimensions.iconSize24,
                    ),
                  ),
                  SizedBox(width: Dimensions.width10),
                  Text(
                    widget.order.purchaseOrderNumber,
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.88,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: Dimensions.height30),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, {required String label, required Widget child}) {
    return Container(
      color: context.colors.card,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height15,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Dimensions.width20 * 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.85,
                fontWeight: FontWeight.w500,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) =>
      Divider(height: 1, color: context.colors.border);
}
