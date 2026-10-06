import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/bottom_sheet_drag_handle.dart';
import 'package:flutter/material.dart';

void showInvoiceMoreOptionsSheet(
  BuildContext context, {
  required TextEditingController customerNameController,
  required VoidCallback onResetForm,
  /// Called when the user taps "Save and send". Pass null to disable the tile
  /// while a save operation is already in progress.
  VoidCallback? onSaveAndSend,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: BoxDecoration(
        color: ctx.colors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius20 * 1.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetDragHandle(),
          _moreOptionTile(
            ctx,
            Icons.remove_red_eye_outlined,
            'Preview invoice',
            () {
              ToastificationHelper.showInfo(
                context,
                'Invoice preview is coming soon.',
              );
            },
          ),
          _moreOptionTile(
            ctx,
            Icons.send_rounded,
            'Save and send',
            onSaveAndSend == null
                ? null
                : () => onSaveAndSend(),
          ),
          _moreOptionTile(
            ctx,
            Icons.refresh_rounded,
            'Reset form',
            () {
              onResetForm();
              ToastificationHelper.showInfo(context, 'Form reset.');
            },
          ),
          SizedBox(height: Dimensions.height20),
        ],
      ),
    ),
  );
}

Widget _moreOptionTile(
  BuildContext sheetContext,
  IconData icon,
  String label,
  VoidCallback? onTap,
) {
  final bool disabled = onTap == null;
  return ListTile(
    enabled: !disabled,
    leading: Icon(
      icon,
      color: disabled ? sheetContext.colors.textTertiary : AppColors.primary,
    ),
    title: Text(
      label,
      style: TextStyle(
        fontSize: Dimensions.font16 * 0.9,
        fontWeight: FontWeight.w600,
        color: disabled
            ? sheetContext.colors.textTertiary
            : sheetContext.colors.textPrimary,
      ),
    ),
    onTap: disabled
        ? null
        : () {
            Navigator.pop(sheetContext);
            onTap();
          },
  );
}
