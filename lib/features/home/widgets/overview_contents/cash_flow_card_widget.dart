import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/widgets/bottom_sheet_header.dart';
import 'package:custom_books/features/home/models/cash_flow_point_model.dart';
import 'package:custom_books/features/home/widgets/card_tile_widget.dart';
import 'package:flutter/material.dart';

String _periodLabel(String value) {
  switch (value) {
    case 'this_fiscal_year':
      return 'This Fiscal Year';
    case 'last_fiscal_year':
      return 'Last Fiscal Year';
    case 'this_year':
      return 'This Year';
    case 'this_month':
      return 'This Month';
    case 'last_month':
      return 'Last Month';
    default:
      return value;
  }
}

class CashFlowCardWidget extends StatefulWidget {
  final List<CashFlowPoint> apiData;
  final List<String> availablePeriods;
  final String asOnLabel;
  final String currency;
  final void Function(String period)? onPeriodChanged;

  const CashFlowCardWidget({
    super.key,
    this.apiData = const [],
    this.availablePeriods = const ['This Fiscal Year'],
    this.asOnLabel = '',
    this.currency = 'INR',
    this.onPeriodChanged,
  });

  @override
  State<CashFlowCardWidget> createState() => _CashFlowCardWidgetState();
}

class _CashFlowCardWidgetState extends State<CashFlowCardWidget> {
  String _selectedPeriod = 'this_fiscal_year';
  int? _tappedIndex;

  String get _sym {
    switch (widget.currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '${widget.currency} ';
    }
  }

  List<CashFlowPoint> get _cashFlowData => widget.apiData;

  void _showPeriodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _PeriodPickerSheet(
        title: 'Select Period',
        sectionLabel: 'CASH FLOW PERIOD',
        selectedPeriod: _selectedPeriod,
        periods: widget.availablePeriods,
        onSelected: (period) {
          Navigator.pop(sheetCtx);
          setState(() => _selectedPeriod = period);
          widget.onPeriodChanged?.call(period);
        },
        onClose: () => Navigator.pop(sheetCtx),
      ),
    );
  }

  void _onChartTap(int index) {
    setState(() {
      _tappedIndex = (_tappedIndex == index) ? null : index;
    });
  }

  void _dismissTooltip() {
    if (_tappedIndex != null) {
      setState(() => _tappedIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cashFlowData.isEmpty) {
      return Container(
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          children: [
            CardTitle(title: 'Cash Flow', icon: Icons.show_chart_rounded),
            SizedBox(height: Dimensions.height30),
            Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: Dimensions.height30),
          ],
        ),
      );
    }
    final sym = _sym;
    final label = widget.asOnLabel.isNotEmpty
        ? widget.asOnLabel
        : 'Opening Balance';
    final totalIncoming = _cashFlowData.fold<double>(0, (p, e) => p + e.income);
    final totalOutgoing = _cashFlowData.fold<double>(
      0,
      (p, e) => p + e.outgoing,
    );
    final last = _cashFlowData.last;
    final first = _cashFlowData.first;

    return GestureDetector(
      onTap: _dismissTooltip,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CardTitle(title: 'Cash Flow', icon: Icons.show_chart_rounded),
                GestureDetector(
                  onTap: _showPeriodSheet,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10,
                      vertical: Dimensions.height10 * 0.4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _periodLabel(_selectedPeriod),
                          style: TextStyle(
                            fontSize: Dimensions.font16 * 0.72,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        SizedBox(width: Dimensions.width10 * 0.4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: Dimensions.iconSize16,
                          color: context.colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),

            SizedBox(
              height: Dimensions.screenHeight / 3.5,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          onTapDown: (details) {
                            final stepX =
                                constraints.maxWidth /
                                (_cashFlowData.length - 1);
                            final index = (details.localPosition.dx / stepX)
                                .round()
                                .clamp(0, _cashFlowData.length - 1);
                            _onChartTap(index);
                          },
                          child: CustomPaint(
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                            painter: _InteractiveAreaChartPainter(
                              data: _cashFlowData,
                              color: AppColors.accent,
                              highlightIndex: _tappedIndex,
                              gridColor: context.colors.border,
                              labelColor: context.colors.textTertiary,
                            ),
                          ),
                        ),
                      ),

                      if (_tappedIndex != null)
                        _buildTooltipOverlay(constraints),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: Dimensions.height10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _cashFlowData
                  .map(
                    (e) => Text(
                      e.month,
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.6,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  )
                  .toList(),
            ),

            Divider(height: Dimensions.height30, color: context.colors.border),

            _statLine(
              context,
              label,
              '$sym${first.opening.toStringAsFixed(2)}',
              context.colors.textPrimary,
              bold: true,
            ),
            _statLine(
              context,
              '+ Incoming',
              '$sym${totalIncoming.toStringAsFixed(2)}',
              AppColors.ok,
            ),
            _statLine(
              context,
              '- Outgoing',
              '$sym${totalOutgoing.toStringAsFixed(2)}',
              AppColors.warn,
            ),
            _statLine(
              context,
              '= Ending Balance',
              '$sym${last.ending.toStringAsFixed(2)}',
              AppColors.accent,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltipOverlay(BoxConstraints constraints) {
    final point = _cashFlowData[_tappedIndex!];
    final values = _cashFlowData.map((e) => e.ending).toList();
    final maxVal = values
        .reduce((a, b) => a > b ? a : b)
        .clamp(1.0, double.infinity);
    final stepX = constraints.maxWidth / (_cashFlowData.length - 1);
    final tooltipWidth = constraints.maxWidth * 0.62;
    final xCenter = _tappedIndex! * stepX;

    final yPoint =
        constraints.maxHeight -
        (values[_tappedIndex!] / maxVal) * constraints.maxHeight;

    double left = xCenter - tooltipWidth / 2;
    if (left < 0) left = 0;
    if (left + tooltipWidth > constraints.maxWidth) {
      left = constraints.maxWidth - tooltipWidth;
    }

    const tooltipEstimatedHeight = 120.0;
    double top = yPoint - tooltipEstimatedHeight - 12;
    if (top < 0) top = yPoint + 16;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: tooltipWidth,
        padding: EdgeInsets.all(Dimensions.width10 * 1.2),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${point.month} 2026',
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.9,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: Dimensions.height10 * 0.6),

            _tooltipRow(
              'Opening Bal.',
              '$_sym${_formatNumber(point.opening)}',
              context.colors.textSecondary,
            ),
            SizedBox(height: Dimensions.height10 * 0.4),

            _tooltipRow(
              'Income',
              '$_sym${_formatNumber(point.income)}',
              AppColors.ok,
            ),
            SizedBox(height: Dimensions.height10 * 0.4),

            _tooltipRow(
              'Outgoing',
              '$_sym${_formatNumber(point.outgoing)}',
              AppColors.warn,
            ),
            SizedBox(height: Dimensions.height10 * 0.4),

            _tooltipRow(
              'Ending Bal.',
              '$_sym${_formatNumber(point.ending)}',
              AppColors.accent,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tooltipRow(
    String label,
    String value,
    Color labelColor, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.78,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.78,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _statLine(
    BuildContext context,
    String label,
    String value,
    Color color, {
    bool bold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height10 / 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              color: bold ? color : context.colors.textSecondary,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Dimensions.font16,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000) {
      return value
          .toStringAsFixed(2)
          .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},');
    }
    return value.toStringAsFixed(2);
  }
}

class _PeriodPickerSheet extends StatelessWidget {
  final String title;
  final String sectionLabel;
  final String selectedPeriod;
  final List<String> periods;
  final ValueChanged<String> onSelected;
  final VoidCallback onClose;

  const _PeriodPickerSheet({
    required this.title,
    required this.sectionLabel,
    required this.selectedPeriod,
    required this.periods,
    required this.onSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimensions.radius20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: Dimensions.height15),
            BottomSheetHeader(title: title, onClose: onClose, showBorder: true),
            Padding(
              padding: EdgeInsets.fromLTRB(
                Dimensions.width20,
                Dimensions.height20,
                Dimensions.width20,
                Dimensions.height10,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  sectionLabel,
                  style: TextStyle(
                    fontSize: Dimensions.font16 * 0.7,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
              child: Column(
                children: [
                  for (int i = 0; i < periods.length; i++) ...[
                    _PeriodTile(
                      period: periods[i],
                      isSelected: periods[i] == selectedPeriod,
                      onTap: () => onSelected(periods[i]),
                    ),
                    if (i < periods.length - 1)
                      SizedBox(height: Dimensions.height10),
                  ],
                ],
              ),
            ),
            SizedBox(height: Dimensions.height20),
          ],
        ),
      ),
    );
  }
}

class _PeriodTile extends StatelessWidget {
  final String period;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTile({
    required this.period,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radius15),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : context.colors.card,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : context.colors.border,
          ),
        ),
        child: Row(
          children: [
            RadioGroup<bool>(
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              child: Radio<bool>(
                value: true,
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            SizedBox(width: Dimensions.width10 * 0.5),
            Expanded(
              child: Text(
                _periodLabel(period),
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : context.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveAreaChartPainter extends CustomPainter {
  final List<CashFlowPoint> data;
  final Color color;
  final int? highlightIndex;
  final Color gridColor;
  final Color labelColor;

  _InteractiveAreaChartPainter({
    required this.data,
    required this.color,
    this.highlightIndex,
    required this.gridColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final values = data.map((e) => e.ending).toList();
    final maxVal = values
        .reduce((a, b) => a > b ? a : b)
        .clamp(1.0, double.infinity);
    final stepX = size.width / (values.length - 1);

    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;

    const gridLines = 5;
    for (int i = 0; i <= gridLines; i++) {
      final y = size.height * i / gridLines;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final labelStyle = TextStyle(color: labelColor, fontSize: 10);
    for (int i = 0; i <= gridLines; i++) {
      final val = maxVal * (gridLines - i) / gridLines;
      final label = _shortNumber(val);
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final y = size.height * i / gridLines - tp.height / 2;
      tp.paint(
        canvas,
        Offset(-tp.width - 4, y.clamp(0, size.height - tp.height)),
      );
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxVal) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = color;
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxVal) * size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    if (highlightIndex != null &&
        highlightIndex! >= 0 &&
        highlightIndex! < values.length) {
      final hx = highlightIndex! * stepX;
      final vertPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(hx, 0), Offset(hx, size.height), vertPaint);

      final hy = size.height - (values[highlightIndex!] / maxVal) * size.height;
      canvas.drawCircle(
        Offset(hx, hy),
        6,
        Paint()..color = color.withValues(alpha: 0.2),
      );
      canvas.drawCircle(Offset(hx, hy), 4, Paint()..color = color);
      canvas.drawCircle(Offset(hx, hy), 2, Paint()..color = Colors.white);
    }
  }

  String _shortNumber(double val) {
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}K';
    return val.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(covariant _InteractiveAreaChartPainter oldDelegate) {
    return oldDelegate.highlightIndex != highlightIndex;
  }
}
