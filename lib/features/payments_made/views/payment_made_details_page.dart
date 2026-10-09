import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/customers/widgets/customer_details_page_widgets/comments_tab.dart';
import 'package:custom_books/features/payments_made/models/payment_made_model.dart';
import 'package:custom_books/features/payments_made/views/add_payment_made_page.dart';
import 'package:custom_books/features/payments_made/widgets/payment_made_details_header.dart';
import 'package:custom_books/features/payments_made/widgets/payment_made_details_tab.dart';
import 'package:flutter/material.dart';

class PaymentMadeDetailsPage extends StatefulWidget {
  final PaymentMadeModel payment;
  const PaymentMadeDetailsPage({super.key, required this.payment});

  @override
  State<PaymentMadeDetailsPage> createState() => _PaymentMadeDetailsPageState();
}

class _PaymentMadeDetailsPageState extends State<PaymentMadeDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomBackAppBar(
        title: 'Payment Details',
        backgroundColor: context.colors.card,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddPaymentMadePage(existing: widget.payment),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
            ),
            surfaceTintColor: context.colors.card,
            color: context.colors.card,
            elevation: 8,
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await showConfirmationDialog(
                  context,
                  title: 'Delete Payment',
                  message:
                      'Are you sure you want to delete this payment? This action cannot be undone.',
                );
                if (confirmed && context.mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              _mi(
                context,
                'print',
                Icons.print_rounded,
                'Print',
                context.colors.textSecondary,
              ),
              _mi(
                context,
                'delete',
                Icons.delete_outline_rounded,
                'Delete',
                AppColors.warn,
              ),
            ],
          ),
          SizedBox(width: Dimensions.width10),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const DetailsPageSkeleton()
            : Column(
                children: [
                  PaymentMadeDetailsHeader(payment: payment),
                  SizedBox(height: Dimensions.height15),
                  _pillTabBar(),
                  SizedBox(height: Dimensions.height15),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        PaymentMadeDetailsTab(payment: payment),
                        const CommentsTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _pillTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      decoration: BoxDecoration(
        color: context.colors.surfaceLight,
        borderRadius: BorderRadius.circular(Dimensions.radius30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(Dimensions.radius30),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: Dimensions.radius15 * 0.53,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.primary,
        unselectedLabelColor: context.colors.textSecondary,
        labelStyle: TextStyle(
          fontSize: Dimensions.font16 * 0.72,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
        dividerColor: Colors.transparent,
        padding: EdgeInsets.all(Dimensions.width10 / 2),
        tabs: const [
          Tab(text: 'DETAILS'),
          Tab(text: 'COMMENTS & HISTORY'),
        ],
      ),
    );
  }

  PopupMenuItem<String> _mi(
    BuildContext ctx,
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: Dimensions.iconSize16 + 4, color: color),
          SizedBox(width: Dimensions.width10),
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              fontWeight: FontWeight.w600,
              color: value == 'delete'
                  ? AppColors.warn
                  : ctx.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
