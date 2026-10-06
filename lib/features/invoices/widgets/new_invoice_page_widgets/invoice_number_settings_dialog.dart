import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:flutter/material.dart';

enum InvoiceNumberMode { autoGenerate, manualEachTime, manualThisInvoice }

class InvoiceNumberResult {
  final InvoiceNumberMode mode;

  /// The full invoice number string to display in the form field.
  /// Null when [mode] is [InvoiceNumberMode.manualEachTime].
  final String? invoiceNumber;

  const InvoiceNumberResult({required this.mode, this.invoiceNumber});
}

/// Dialog shown when the user taps the gear icon next to the Invoice# field.
/// Returns an [InvoiceNumberResult] on Save, or null on Cancel.
class InvoiceNumberSettingsDialog extends StatefulWidget {
  final String currentInvoiceNumber;

  const InvoiceNumberSettingsDialog({
    super.key,
    required this.currentInvoiceNumber,
  });

  static Future<InvoiceNumberResult?> show(
    BuildContext context, {
    required String currentInvoiceNumber,
  }) {
    return showGeneralDialog<InvoiceNumberResult>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Invoice Number Settings',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, anim, ignored, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, a1, a2) => InvoiceNumberSettingsDialog(
        currentInvoiceNumber: currentInvoiceNumber,
      ),
    );
  }

  @override
  State<InvoiceNumberSettingsDialog> createState() =>
      _InvoiceNumberSettingsDialogState();
}

class _InvoiceNumberSettingsDialogState
    extends State<InvoiceNumberSettingsDialog> {
  late InvoiceNumberMode _mode;
  late TextEditingController _prefixController;
  late TextEditingController _nextNumberController;

  @override
  void initState() {
    super.initState();
    _mode = InvoiceNumberMode.autoGenerate;

    // Parse 'INV-000039' → prefix='INV-'  next='000039'
    final current = widget.currentInvoiceNumber;
    final dashIndex = current.lastIndexOf('-');
    if (dashIndex != -1 && dashIndex < current.length - 1) {
      _prefixController = TextEditingController(
        text: '${current.substring(0, dashIndex)}-',
      );
      _nextNumberController = TextEditingController(
        text: current.substring(dashIndex + 1),
      );
    } else {
      _prefixController = TextEditingController(text: 'INV-');
      _nextNumberController = TextEditingController(text: current);
    }
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _nextNumberController.dispose();
    super.dispose();
  }

  void _save() {
    String? invoiceNumber;
    switch (_mode) {
      case InvoiceNumberMode.autoGenerate:
      case InvoiceNumberMode.manualThisInvoice:
        final prefix = _prefixController.text.trim();
        final next = _nextNumberController.text.trim();
        invoiceNumber = next.isEmpty ? prefix : '$prefix$next';
        break;
      case InvoiceNumberMode.manualEachTime:
        invoiceNumber = null;
        break;
    }
    Navigator.of(
      context,
    ).pop(InvoiceNumberResult(mode: _mode, invoiceNumber: invoiceNumber));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20 * 1.2),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(Dimensions.radius20),
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: Dimensions.radius20 * 1.2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radius20),
                      topRight: Radius.circular(Dimensions.radius20),
                    ),
                    border: Border(bottom: BorderSide(color: colors.border)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(Dimensions.width10 * 0.8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius15 / 2,
                          ),
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          color: AppColors.primary,
                          size: Dimensions.iconSize24,
                        ),
                      ),
                      SizedBox(width: Dimensions.width10),
                      Text(
                        'Invoice Number',
                        style: TextStyle(
                          fontSize: Dimensions.font20 * 0.95,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Options ────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    Dimensions.height20,
                    Dimensions.width20,
                    Dimensions.height10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Option 1 — auto-generate
                      _RadioOption(
                        selected: _mode == InvoiceNumberMode.autoGenerate,
                        label: 'Continue auto-generating invoice numbers',
                        onTap: () => setState(
                          () => _mode = InvoiceNumberMode.autoGenerate,
                        ),
                      ),

                      // Prefix + Next Number (visible only for auto-generate)
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState: _mode == InvoiceNumberMode.autoGenerate
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Padding(
                          padding: EdgeInsets.fromLTRB(
                            Dimensions.width20 + Dimensions.iconSize24,
                            Dimensions.height10,
                            0,
                            Dimensions.height10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _NumberField(
                                  label: 'Prefix',
                                  controller: _prefixController,
                                  hint: 'INV-',
                                ),
                              ),
                              SizedBox(width: Dimensions.width15),
                              Expanded(
                                child: _NumberField(
                                  label: 'Next Number',
                                  controller: _nextNumberController,
                                  hint: '000001',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                        secondChild: const SizedBox.shrink(),
                      ),

                      SizedBox(height: Dimensions.height10),

                      // Option 2 — manual each time
                      _RadioOption(
                        selected: _mode == InvoiceNumberMode.manualEachTime,
                        label: 'I will add them manually each time',
                        onTap: () => setState(
                          () => _mode = InvoiceNumberMode.manualEachTime,
                        ),
                      ),

                      SizedBox(height: Dimensions.height10),

                      // Option 3 — manual for this invoice only
                      _RadioOption(
                        selected: _mode == InvoiceNumberMode.manualThisInvoice,
                        label: 'I will add them manually only for this invoice',
                        onTap: () => setState(
                          () => _mode = InvoiceNumberMode.manualThisInvoice,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(color: colors.border, height: 1),

                // ── Actions ────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    Dimensions.height15,
                    Dimensions.width20,
                    Dimensions.height20,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(null),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height15,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceLight,
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius15 / 2,
                              ),
                              border: Border.all(color: colors.border),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.85,
                                fontWeight: FontWeight.w700,
                                color: colors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Dimensions.width10),
                      Expanded(
                        child: GestureDetector(
                          onTap: _save,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimensions.height15,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius15 / 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'SAVE',
                              style: TextStyle(
                                fontSize: Dimensions.font16 * 0.85,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

class _RadioOption extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _RadioOption({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: Dimensions.height10 * 0.25),
            child: Container(
              width: Dimensions.iconSize24,
              height: Dimensions.iconSize24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : context.colors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: Dimensions.iconSize24 / 2,
                        height: Dimensions.iconSize24 / 2,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(width: Dimensions.width10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: Dimensions.height10 * 0.3),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.88,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _NumberField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.75,
            fontWeight: FontWeight.w600,
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: Dimensions.height10 / 2),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.88,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.colors.textTertiary),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.width10,
              vertical: Dimensions.height10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
              borderSide: BorderSide(color: context.colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
