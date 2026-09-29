import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/bottom_sheet_drag_handle.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/features/customers/controllers/customer_detail_controller.dart';
import 'package:custom_books/features/customers/controllers/customer_form_controller.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:custom_books/features/customers/views/add_customer_page.dart';
import 'package:custom_books/features/customers/widgets/customer_details_page_widgets/comments_tab.dart';
import 'package:custom_books/features/customers/widgets/customer_details_page_widgets/contact_information_section.dart';
import 'package:custom_books/features/customers/widgets/customer_details_page_widgets/contact_persons_section.dart';
import 'package:custom_books/features/customers/widgets/customer_details_page_widgets/more_information_section.dart';
import 'package:custom_books/features/customers/widgets/customer_details_page_widgets/receivables_section_card.dart';
import 'package:custom_books/features/customers/widgets/customer_details_page_widgets/transactions_tab.dart';
import 'package:custom_books/features/invoices/views/new_invoice_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';

class CustomerDetailsPage extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailsPage({super.key, required this.customer});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  final CustomerDetailController _controller = CustomerDetailController();
  final CustomerFormController _formController = CustomerFormController();

  /// The customer currently displayed: the freshly fetched one when available,
  /// otherwise the (partial) customer passed in from the list.
  CustomerModel get _customer => _controller.customer ?? widget.customer;

  bool get _isLoading => _controller.isLoading && _controller.customer == null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    appLog(
      '🎯 CustomerDetailsPage initialized for: ${widget.customer.name}',
      name: 'CustomerDetailsPage',
    );
    _controller.addListener(_onControllerChanged);
    _load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _formController.dispose();
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleStatus() async {
    final current = _customer;
    final newStatus = current.isActive ? 'inactive' : 'active';
    final label = current.isActive ? 'inactive' : 'active';

    final ok = await _formController.patch(current.id, {'status': newStatus});
    if (!mounted) return;

    if (ok) {
      ToastificationHelper.showSuccess(
        context,
        '${current.name} marked as $label.',
      );
      await _load();
    } else {
      ToastificationHelper.showError(
        context,
        _formController.errorMessage ?? 'Could not update status.',
      );
    }
  }

  Future<void> _load() async {
    await _controller.load(widget.customer.id);
    if (!mounted) return;
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  void _editCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCustomerPage(customer: _customer)),
    );
  }

  Future<void> _dial(String? number) async {
    if (number == null || number.trim().isEmpty) {
      _editCustomer();
      return;
    }
    final uri = Uri(scheme: 'tel', path: number.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ToastificationHelper.showError(context, 'Could not open the dialer.');
    }
  }

  Future<void> _sendEmail(String? email) async {
    if (email == null || email.trim().isEmpty) {
      _editCustomer();
      return;
    }
    final uri = Uri(scheme: 'mailto', path: email.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ToastificationHelper.showError(context, 'Could not open the mail app.');
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        Widget tile(IconData icon, String label, VoidCallback onTap) {
          return ListTile(
            leading: Icon(icon, color: AppColors.primary),
            title: Text(
              label,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.9,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(ctx);
              onTap();
            },
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(Dimensions.radius20 * 1.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetDragHandle(),
              tile(Icons.edit_outlined, 'Edit customer', _editCustomer),
              tile(
                Icons.share_outlined,
                'Share details',
                () => ToastificationHelper.showInfo(
                  context,
                  'Sharing customer details is coming soon.',
                ),
              ),
              tile(
                _customer.isActive
                    ? Icons.block_rounded
                    : Icons.check_circle_outline_rounded,
                _customer.isActive ? 'Mark as inactive' : 'Mark as active',
                () {
                  Navigator.pop(ctx);
                  _toggleStatus();
                },
              ),
              SizedBox(height: Dimensions.height20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    appLog('🏗️ Building CustomerDetailsPage', name: 'CustomerDetailsPage');
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: _isLoading
            ? const DetailsPageSkeleton(
                headerStyle: DetailsHeaderStyle.twoMetric,
                tabStyle: DetailsTabStyle.underline,
                tabCount: 3,
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  CustomSliverAppBar(
                    title: _customer.name,
                    leadingType: AppBarLeadingType.back,
                    onLeadingPressed: () {
                      appLog(
                        '⬅️ Back button pressed',
                        name: 'CustomerDetailsPage',
                      );
                      Navigator.pop(context);
                    },
                    actions: [
                      AppBarIconButton(
                        icon: Icons.edit_outlined,
                        color: AppColors.primary,
                        onPressed: () {
                          appLog(
                            '✏️ Edit button pressed',
                            name: 'CustomerDetailsPage',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddCustomerPage(customer: _customer),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: Dimensions.width10),
                      AppBarIconButton(
                        icon: Icons.attach_file_rounded,
                        color: context.colors.textSecondary,
                        onPressed: () {
                          appLog(
                            '📎 Attachment button pressed',
                            name: 'CustomerDetailsPage',
                          );
                          ToastificationHelper.showInfo(
                            context,
                            'Attachments for customers are coming soon.',
                          );
                        },
                      ),
                      SizedBox(width: Dimensions.width10),
                      AppBarIconButton(
                        icon: Icons.more_vert_rounded,
                        color: context.colors.textSecondary,
                        onPressed: _showMoreOptions,
                      ),
                      SizedBox(width: Dimensions.width20),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Dimensions.width20),
                      decoration: BoxDecoration(
                        color: context.colors.card,
                        border: Border(
                          bottom: BorderSide(
                            color: context.colors.border,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Receivables',
                                  style: TextStyle(
                                    fontSize: Dimensions.font16 * 0.75,
                                    color: context.colors.textTertiary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: Dimensions.height10 / 2),
                                Text(
                                  '₹${_customer.receivables.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: Dimensions.font26,
                                    fontWeight: FontWeight.w800,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            height: Dimensions.height45,
                            width: 1,
                            color: context.colors.border,
                          ),

                          SizedBox(width: Dimensions.width20),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Unused Credits',
                                  style: TextStyle(
                                    fontSize: Dimensions.font16 * 0.75,
                                    color: context.colors.textTertiary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: Dimensions.height10 / 2),
                                Text(
                                  '₹${_customer.unusedCredits.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: Dimensions.font26,
                                    fontWeight: FontWeight.w800,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colors.card,
                        border: Border(
                          bottom: BorderSide(
                            color: context.colors.border,
                            width: 1,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: context.colors.textSecondary,
                        labelStyle: TextStyle(
                          fontSize: Dimensions.font16 * 0.8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: Dimensions.font16 * 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(text: 'DETAILS'),
                          Tab(text: 'TRANSACTIONS'),
                          Tab(text: 'COMMENTS'),
                        ],
                      ),
                    ),
                  ),

                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(height: Dimensions.height20),

                              ContactInformationSection(
                                customer: _customer,
                                onDial: _dial,
                                onSendEmail: _sendEmail,
                              ),

                              ReceivablesSectionCard(
                                customer: _customer,
                                onEditCustomer: _editCustomer,
                              ),

                              MoreInformationSection(customer: _customer),

                              ContactPersonsSection(customer: _customer),

                              SizedBox(height: Dimensions.height30),
                            ],
                          ),
                        ),
                        const TransactionsTab(),
                        const CommentsTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          if (_tabController.index == 1) {
            return FloatingActionButton(
              onPressed: () {
                appLog(
                  '➕ Add Transaction FAB tapped',
                  name: 'CustomerDetailsPage',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewInvoicePage(customer: _customer),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius20),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: Dimensions.iconSize24 * 1.2,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
