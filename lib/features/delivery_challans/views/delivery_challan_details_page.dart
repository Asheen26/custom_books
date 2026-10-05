import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/detail_row.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/delivery_challans/controllers/delivery_challan_detail_controller.dart';
import 'package:custom_books/features/delivery_challans/models/delivery_challan_model.dart';
import 'package:custom_books/features/delivery_challans/views/add_delivery_challan_page.dart';
import 'package:flutter/material.dart';

class DeliveryChallanDetailsPage extends StatefulWidget {
  final DeliveryChallanModel challan;

  const DeliveryChallanDetailsPage({super.key, required this.challan});

  @override
  State<DeliveryChallanDetailsPage> createState() =>
      _DeliveryChallanDetailsPageState();
}

class _DeliveryChallanDetailsPageState extends State<DeliveryChallanDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DeliveryChallanDetailController _controller =
      DeliveryChallanDetailController();

  DeliveryChallanModel get _challan => _controller.challan ?? widget.challan;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller.seed(widget.challan);
    _controller.addListener(_onControllerChanged);
    _load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    await _controller.load(widget.challan.id);
    if (!mounted) return;
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final challan = _challan;
    final statusColor = challan.status.color;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomBackAppBar(
        title: 'Delivery Challan Details',
        backgroundColor: context.colors.card,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            onPressed: () async {
              final updated = await Navigator.push<DeliveryChallanModel>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddDeliveryChallanPage(existing: _challan),
                ),
              );
              if (updated != null && mounted) {
                _load();
              }
            },
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
              if (value == 'print') {
                ToastificationHelper.showInfo(
                  context,
                  'Printing delivery challans is coming soon.',
                );
              } else if (value == 'delete') {
                final confirmed = await showConfirmationDialog(
                  context,
                  title: 'Delete Delivery Challan',
                  message:
                      'Are you sure you want to delete this delivery challan? '
                      'This action cannot be undone.',
                );
                if (confirmed && context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(
                      Icons.print_rounded,
                      size: Dimensions.iconSize16 + 4,
                      color: context.colors.textSecondary,
                    ),
                    SizedBox(width: Dimensions.width10),
                    Text(
                      'Print',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.85,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: Dimensions.iconSize16 + 4,
                      color: AppColors.warn,
                    ),
                    SizedBox(width: Dimensions.width10),
                    Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.85,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warn,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(width: Dimensions.width10),
        ],
      ),
      body: SafeArea(
        child: _controller.isLoading
            ? const DetailsPageSkeleton()
            : Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Dimensions.width20),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x08000000),
                          blurRadius: Dimensions.radius15 * 0.53,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.7,
                                color: context.colors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.width10 + 2,
                                vertical: Dimensions.height10 * 0.5,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radius30,
                                ),
                              ),
                              child: Text(
                                challan.status.label,
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.62,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.height10 / 2.5),
                        Text(
                          formatDate(challan.challanDate),
                          style: TextStyle(
                            fontSize: Dimensions.font20 * 0.95,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: Dimensions.height20),
                        Text(
                          challan.customerName,
                          style: TextStyle(
                            fontSize: Dimensions.font20 * 0.95,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: Dimensions.height10 / 2.5),
                        Text(
                          challan.challanNumber,
                          style: TextStyle(
                            fontSize: Dimensions.font16 * 0.85,
                            color: context.colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height15),

                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceLight,
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: context.colors.card,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius30,
                        ),
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
                  ),
                  SizedBox(height: Dimensions.height15),

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDetailsTab(challan),
                        _buildCommentsTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDetailsTab(DeliveryChallanModel challan) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      physics: const BouncingScrollPhysics(),
      children: [
        _card(
          children: [
            DetailRow(label: 'Challan#:', value: challan.challanNumber),
            SizedBox(height: Dimensions.height15),
            DetailRow(
              label: 'Reference#:',
              value: challan.referenceNumber.isEmpty
                  ? '-'
                  : challan.referenceNumber,
            ),
            SizedBox(height: Dimensions.height15),
            DetailRow(label: 'Type:', value: challan.type),
            SizedBox(height: Dimensions.height15),
            DetailRow(
              label: 'Amount:',
              value: '₹${challan.total.toStringAsFixed(2)}',
            ),
          ],
        ),
        SizedBox(height: Dimensions.height15),

        if (challan.lineItems.isNotEmpty)
          _card(
            children: [
              Text(
                'Line Items',
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.95,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: Dimensions.height15),
              ...challan.lineItems.map(
                (item) => Container(
                  margin: EdgeInsets.only(bottom: Dimensions.height10),
                  padding: EdgeInsets.all(Dimensions.width15),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.itemName,
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.88,
                                fontWeight: FontWeight.w700,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            if (item.description.isNotEmpty) ...[
                              SizedBox(height: Dimensions.height10 / 4),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.72,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                            SizedBox(height: Dimensions.height10 / 2),
                            Text(
                              '${item.quantity.toStringAsFixed(2)} × '
                              '₹${item.rate.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.72,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${item.gross.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: Dimensions.font16 * 0.88,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),
              Padding(
                padding: EdgeInsets.only(top: Dimensions.height10 / 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.9,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Text(
                      '₹${challan.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.95,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        SizedBox(height: Dimensions.height30),
      ],
    );
  }

  Widget _buildCommentsTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Dimensions.width20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(Dimensions.width20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: Dimensions.iconSize24 * 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'No comments or history yet',
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.95,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              'Comments and activity history\nwill appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.8,
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) => Container(
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
      children: children,
    ),
  );
}
