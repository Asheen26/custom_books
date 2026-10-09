import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/date_formatter.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_back_appbar.dart';
import 'package:custom_books/core/widgets/form_widgets.dart';
import 'package:custom_books/features/purchase_orders/models/purchase_order_model.dart';
import 'package:flutter/material.dart';

/// Full-screen form for creating a new Purchase Receive against a PO.
class PoNewReceivePage extends StatefulWidget {
  final PurchaseOrderModel order;

  const PoNewReceivePage({super.key, required this.order});

  @override
  State<PoNewReceivePage> createState() => _PoNewReceivePageState();
}

class _PoNewReceivePageState extends State<PoNewReceivePage> {
  final _receiveNumController = TextEditingController(text: 'PR-00010');
  final _notesController = TextEditingController();
  final _itemSearchController = TextEditingController();
  DateTime _receivedDate = DateTime.now();
  bool _selectScanItems = true;

  @override
  void dispose() {
    _receiveNumController.dispose();
    _notesController.dispose();
    _itemSearchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _receivedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _receivedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomBackAppBar(
        title: 'New Purchase Receive',
        backgroundColor: context.colors.card,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          Dimensions.width15,
          Dimensions.height15,
          Dimensions.width15,
          Dimensions.height30,
        ),
        child: Column(
          children: [
            // ── Card 1: Receive# / Date / loss ─────────────────────────
            FormCard(
              children: [
                const RequiredLabel(text: 'Purchase Receive#'),
                SizedBox(height: Dimensions.height10 / 2),
                _fieldRow(
                  context,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _receiveNumController.text,
                          style: FormTextStyles.value(context),
                        ),
                      ),
                      Icon(
                        Icons.settings_outlined,
                        size: Dimensions.iconSize24 * 0.85,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                const RequiredLabel(text: 'Received Date'),
                SizedBox(height: Dimensions.height10 / 2),
                InkWell(
                  onTap: _pickDate,
                  child: _fieldRow(
                    context,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDate(_receivedDate),
                          style: FormTextStyles.value(context),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: Dimensions.iconSize24 * 0.85,
                          color: context.colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                Text('loss', style: FormTextStyles.label()),
                SizedBox(height: Dimensions.height10 / 2),
                TextField(
                  style: FormTextStyles.value(context),
                  decoration: _underlineDeco(context),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height15),

            // ── Card 2: Select/scan items ───────────────────────────────
            FormCard(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select/scan items',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.9,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Switch(
                      value: _selectScanItems,
                      onChanged: (v) => setState(() => _selectScanItems = v),
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                    ),
                  ],
                ),
                if (_selectScanItems) ...[
                  SizedBox(height: Dimensions.height10 / 2),
                  Text(
                    'You can add/scan the items to be received. Only the items '
                    'selected below would be included in the receive.',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.75,
                      color: context.colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: Dimensions.height15),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width15,
                      vertical: Dimensions.height10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.colors.border),
                      borderRadius: BorderRadius.circular(Dimensions.radius15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _itemSearchController,
                            style: TextStyle(
                              fontSize: Dimensions.font16 * 0.88,
                              color: context.colors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Start typing to select an Item',
                              hintStyle: TextStyle(
                                color: context.colors.textTertiary,
                                fontSize: Dimensions.font16 * 0.88,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          color: context.colors.textSecondary,
                          size: Dimensions.iconSize24,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: Dimensions.height15),

            // ── Card 3: Notes ───────────────────────────────────────────
            FormCard(
              children: [
                Text('Notes (For Internal Use)', style: FormTextStyles.label()),
                SizedBox(height: Dimensions.height10 / 2),
                TextField(
                  controller: _notesController,
                  style: FormTextStyles.value(context),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: _underlineDeco(context),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Dimensions.width15,
            Dimensions.height10,
            Dimensions.width15,
            Dimensions.height15,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ToastificationHelper.showSuccess(
                      context,
                      'Saved as In Transit.',
                    );
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.colors.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height15,
                    ),
                  ),
                  child: Text(
                    'Save as In Transit',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.82,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Dimensions.width10),

              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    ToastificationHelper.showSuccess(
                      context,
                      'Saved as Received.',
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height15,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save as Received',
                    style: TextStyle(
                      fontSize: Dimensions.font16 * 0.9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Dimensions.width10),

              OutlinedButton(
                onPressed: () => ToastificationHelper.showInfo(
                  context,
                  'More options coming soon.',
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.colors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius30),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width15,
                    vertical: Dimensions.height15,
                  ),
                  minimumSize: Size.zero,
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  Widget _fieldRow(BuildContext context, {required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height10 / 2),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.border)),
      ),
      child: child,
    );
  }

  InputDecoration _underlineDeco(BuildContext context) {
    return InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: Dimensions.height10),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: context.colors.border),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: context.colors.border),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }
}
