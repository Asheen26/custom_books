import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/confirmation_dialog.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/features/inventory_adjustments/controllers/adjustment_comments_controller.dart';
import 'package:custom_books/features/inventory_adjustments/controllers/inventory_adjustment_detail_controller.dart';
import 'package:custom_books/features/inventory_adjustments/models/inventory_adjustments_model.dart';
import 'package:custom_books/features/inventory_adjustments/views/add_adjustment_page.dart';
import 'package:custom_books/features/inventory_adjustments/widgets/adjustment_comments_tab.dart';
import 'package:custom_books/features/inventory_adjustments/widgets/adjustment_details_header.dart';
import 'package:custom_books/features/inventory_adjustments/widgets/adjustment_details_tab.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AdjustmentDetailsPage extends StatefulWidget {
  final InventoryAdjustment adjustment;
  const AdjustmentDetailsPage({super.key, required this.adjustment});

  @override
  State<AdjustmentDetailsPage> createState() => _AdjustmentDetailsPageState();
}

class _AdjustmentDetailsPageState extends State<AdjustmentDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InventoryAdjustmentDetailController _controller =
      InventoryAdjustmentDetailController();
  late final AdjustmentCommentsController _commentsController =
      AdjustmentCommentsController(widget.adjustment.id);
  final TextEditingController _commentInputController = TextEditingController();
  final List<PlatformFile> _attachments = [];

  InventoryAdjustment get _adjustment =>
      _controller.adjustment ?? widget.adjustment;
  bool get _isLoading => _controller.isLoading;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller.seed(widget.adjustment);
    _controller.addListener(_rebuild);
    _commentsController.addListener(_rebuild);
    _load();
    _commentsController.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _controller.dispose();
    _commentsController.removeListener(_rebuild);
    _commentsController.dispose();
    _commentInputController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    await _controller.load(widget.adjustment.id);
    if (!mounted) return;
    if (_controller.errorMessage != null) {
      ToastificationHelper.showError(context, _controller.errorMessage!);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentInputController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    final ok = await _commentsController.submit(text);
    if (!mounted) return;
    if (ok) {
      _commentInputController.clear();
    } else if (_commentsController.errorMessage != null) {
      ToastificationHelper.showError(
        context,
        _commentsController.errorMessage!,
      );
    }
  }

  void _showAttachmentsDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => Dialog(
        backgroundColor: context.colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius20),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height45 * 1.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Attachments',
                      style: TextStyle(
                        fontSize: Dimensions.font20 * 0.95,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.close_rounded,
                      size: Dimensions.iconSize24,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.colors.border),
            Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionBtn(
                    Icons.download_rounded,
                    () => ToastificationHelper.showInfo(
                      context,
                      'Downloading coming soon.',
                    ),
                  ),
                  _actionBtn(
                    Icons.delete_outline_rounded,
                    () => ToastificationHelper.showInfo(
                      context,
                      'Removing coming soon.',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: Dimensions.width20,
                bottom: Dimensions.height20,
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles();
                    if (result == null || result.files.isEmpty) return;
                    setState(() => _attachments.addAll(result.files));
                    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                    if (!mounted) return;
                    ToastificationHelper.showSuccess(
                      context,
                      '${result.files.length} attachment(s) added.',
                    );
                  },
                  backgroundColor: AppColors.primary,
                  child: const Icon(
                    Icons.attach_file_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(Dimensions.radius15),
    child: Container(
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: context.colors.surfaceLight,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: context.colors.border),
      ),
      child: Icon(
        icon,
        size: Dimensions.iconSize24,
        color: context.colors.textPrimary,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final adjustment = _adjustment;
    final isDraft = adjustment.status == AdjustmentStatus.draft;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomBackAppBar(
        title: 'Adjustment Details',
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
                builder: (_) => NewAdjustmentPage(existing: _adjustment),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.save_alt_rounded,
              color: context.colors.textSecondary,
              size: Dimensions.iconSize24 - 2,
            ),
            onPressed: () => ToastificationHelper.showInfo(
              context,
              'Exporting as PDF is coming soon.',
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
              if (value == 'convert') {
                ToastificationHelper.showSuccess(
                  context,
                  'Adjustment marked as completed',
                );
              } else if (value == 'print') {
                ToastificationHelper.showInfo(
                  context,
                  'Generating PDF for print...',
                );
              } else if (value == 'delete') {
                final confirmed = await showConfirmationDialog(
                  context,
                  title: 'Delete Adjustment',
                  message:
                      'Are you sure you want to delete this adjustment? This action cannot be undone.',
                );
                if (confirmed && context.mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              if (isDraft)
                _menuItem(
                  context,
                  'convert',
                  Icons.check_circle_outline_rounded,
                  'Convert to Adjusted',
                  AppColors.primary,
                ),
              _menuItem(
                context,
                'print',
                Icons.print_rounded,
                'Print',
                context.colors.textSecondary,
              ),
              _menuItem(
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
                  AdjustmentDetailsHeader(
                    adjustment: adjustment,
                    attachmentCount: _attachments.length,
                    onAttachmentTap: _showAttachmentsDialog,
                  ),
                  SizedBox(height: Dimensions.height15),
                  _pillTabBar(),
                  SizedBox(height: Dimensions.height15),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        AdjustmentDetailsTab(adjustment: adjustment),
                        AdjustmentCommentsTab(
                          commentsController: _commentsController,
                          inputController: _commentInputController,
                          onSubmit: _submitComment,
                        ),
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

  PopupMenuItem<String> _menuItem(
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
