// Widget responsável por exibir o resumo visual do token de uma startup.
//
// Isola preço atual, variação, seletor de período e gráfico, mantendo
// a StartupDetailPage focada apenas nos dados e na organização da tela.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_metric_card.dart';
import '../pages/startup_detail_page.dart';

class StartupTokenOverviewCard extends StatelessWidget {
  final double currentPrice;
  final double variation;
  final bool isPositive;
  final List<double> chartValues;
  final List<String> chartLabels;
  final String subtitle;
  final ChartPeriod selectedPeriod;
  final ValueChanged<ChartPeriod> onPeriodChanged;

  const StartupTokenOverviewCard({
    super.key,
    required this.currentPrice,
    required this.variation,
    required this.isPositive,
    required this.chartValues,
    required this.chartLabels,
    required this.subtitle,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Resumo do token',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _ChartPeriodSelector(
            selectedPeriod: selectedPeriod,
            onPeriodChanged: onPeriodChanged,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: AppMetricCard(
                  label: 'Preço atual',
                  value:
                      'R\$ ${currentPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                  icon: Icons.payments_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppMetricCard(
                  label: 'Variação',
                  value:
                      '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}%',
                  icon: Icons.show_chart_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 230,
            child: StartupLineChart(
              values: chartValues,
              labels: chartLabels,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPeriodSelector extends StatelessWidget {
  final ChartPeriod selectedPeriod;
  final ValueChanged<ChartPeriod> onPeriodChanged;

  const _ChartPeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _PeriodButton(
            label: 'Dia',
            period: ChartPeriod.day,
            selectedPeriod: selectedPeriod,
            onTap: onPeriodChanged,
          ),
          _PeriodButton(
            label: 'Semana',
            period: ChartPeriod.week,
            selectedPeriod: selectedPeriod,
            onTap: onPeriodChanged,
          ),
          _PeriodButton(
            label: 'Mês',
            period: ChartPeriod.month,
            selectedPeriod: selectedPeriod,
            onTap: onPeriodChanged,
          ),
          _PeriodButton(
            label: '6M',
            period: ChartPeriod.sixMonths,
            selectedPeriod: selectedPeriod,
            onTap: onPeriodChanged,
          ),
          _PeriodButton(
            label: 'Ano',
            period: ChartPeriod.year,
            selectedPeriod: selectedPeriod,
            onTap: onPeriodChanged,
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final ChartPeriod period;
  final ChartPeriod selectedPeriod;
  final ValueChanged<ChartPeriod> onTap;

  const _PeriodButton({
    required this.label,
    required this.period,
    required this.selectedPeriod,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  isSelected ? AppColors.primaryLight : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class StartupLineChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;

  const StartupLineChart({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  State<StartupLineChart> createState() => _StartupLineChartState();
}

class _StartupLineChartState extends State<StartupLineChart> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant StartupLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.values != widget.values || oldWidget.labels != widget.labels) {
      _selectedIndex = null;
    }
  }

  void _selectNearestPoint(Offset localPosition, double width) {
    final itemCount = widget.values.length < widget.labels.length
        ? widget.values.length
        : widget.labels.length;

    if (itemCount == 0) return;

    const leftPadding = 64.0;
    const rightPadding = 22.0;
    final availableWidth = width - leftPadding - rightPadding;

    if (availableWidth <= 0) return;

    final rawIndex = itemCount == 1
        ? 0
        : ((localPosition.dx - leftPadding) / availableWidth * (itemCount - 1))
            .round();

    setState(() {
      _selectedIndex = rawIndex.clamp(0, itemCount - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            _selectNearestPoint(details.localPosition, constraints.maxWidth);
          },
          onHorizontalDragStart: (details) {
            _selectNearestPoint(details.localPosition, constraints.maxWidth);
          },
          onHorizontalDragUpdate: (details) {
            _selectNearestPoint(details.localPosition, constraints.maxWidth);
          },
          child: CustomPaint(
            painter: _StartupLineChartPainter(
              values: widget.values,
              labels: widget.labels,
              selectedIndex: _selectedIndex,
            ),
            child: Container(),
          ),
        );
      },
    );
  }
}

class _StartupLineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final int? selectedIndex;

  _StartupLineChartPainter({
    required this.values,
    required this.labels,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || labels.isEmpty) return;

    final itemCount =
        values.length < labels.length ? values.length : labels.length;

    if (itemCount == 0) return;

    const leftPadding = 64.0;
    const rightPadding = 22.0;
    const topPadding = 14.0;
    const bottomPadding = 34.0;
    final chartHeight = size.height - topPadding - bottomPadding;
    final chartBottom = topPadding + chartHeight;
    final availableWidth = size.width - leftPadding - rightPadding;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.2;

    final linePaint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 3.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x3334D399),
          Color(0x0034D399),
        ],
      ).createShader(
        Rect.fromLTWH(
          leftPadding,
          topPadding,
          availableWidth,
          chartHeight,
        ),
      );

    final pointGlowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = const Color(0xFF04111D)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final visibleValues = values.take(itemCount).toList();
    final minValue = visibleValues.reduce((a, b) => a < b ? a : b);
    final maxValue = visibleValues.reduce((a, b) => a > b ? a : b);
    final rawRange = maxValue - minValue;
    final padding = rawRange == 0 ? maxValue.abs() * 0.08 : rawRange * 0.18;
    final chartMin = minValue - padding;
    final chartMax = maxValue + padding;
    final range = (chartMax - chartMin) == 0 ? 1.0 : (chartMax - chartMin);

    for (int i = 0; i <= 4; i++) {
      final y = topPadding + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      final value = chartMax - (range * i / 4);
      _paintText(
        canvas: canvas,
        text: 'R\$ ${_formatPriceAxisValue(value)}',
        x: 0,
        y: y - 8,
        maxWidth: leftPadding - 8,
        color: AppColors.textSecondary,
        fontSize: 10.5,
        textAlign: TextAlign.right,
      );
    }

    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, chartBottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(leftPadding, chartBottom),
      Offset(size.width - rightPadding, chartBottom),
      axisPaint,
    );

    final points = <Offset>[];

    for (int i = 0; i < itemCount; i++) {
      final x = itemCount == 1
          ? leftPadding + availableWidth / 2
          : leftPadding + (availableWidth / (itemCount - 1)) * i;

      final normalized = (values[i] - chartMin) / range;

      final y = chartBottom - (normalized * chartHeight);

      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chartBottom)
      ..lineTo(points.first.dx, chartBottom)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    final activeIndex = (selectedIndex ?? itemCount - 1).clamp(0, itemCount - 1);
    final activePoint = points[activeIndex];

    canvas.drawLine(
      Offset(activePoint.dx, chartBottom),
      activePoint,
      Paint()
        ..color = AppColors.primaryLight.withValues(alpha: 0.28)
        ..strokeWidth = 1.2,
    );

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isActive = i == activeIndex;

      canvas.drawCircle(point, isActive ? 8 : 6.5, pointGlowPaint);
      canvas.drawCircle(point, isActive ? 5.4 : 4.6, pointBorderPaint);
      canvas.drawCircle(point, isActive ? 3.8 : 3.2, pointPaint);
    }

    _paintValueBubble(
      canvas: canvas,
      text:
          '${labels[activeIndex]}  R\$ ${_formatSelectedPriceValue(values[activeIndex])}',
      anchor: activePoint,
      size: size,
    );

    final labelStep = itemCount > 8 ? 2 : 1;
    for (int i = 0; i < itemCount; i++) {
      if (i != itemCount - 1 && i % labelStep != 0) continue;
      if (itemCount > 8 && i == itemCount - 2) continue;

      final label = labels[i];
      final point = points[i];
      const labelWidth = 48.0;
      final labelX =
          (point.dx - labelWidth / 2).clamp(0.0, size.width - labelWidth);

      _paintText(
        canvas: canvas,
        text: label,
        x: labelX,
        y: chartBottom + 12,
        maxWidth: labelWidth,
        color:
            i == activeIndex ? AppColors.primaryLight : AppColors.textSecondary,
        fontSize: 11,
        textAlign: TextAlign.center,
      );
    }
  }

  void _paintValueBubble({
    required Canvas canvas,
    required String text,
    required Offset anchor,
    required Size size,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    const horizontalPadding = 8.0;
    const verticalPadding = 5.0;
    final width = textPainter.width + horizontalPadding * 2;
    final height = textPainter.height + verticalPadding * 2;

    var left = anchor.dx - width / 2;
    var top = anchor.dy - height - 10;

    if (left < 0) left = 0;
    if (left + width > size.width) left = size.width - width;
    if (top < 0) top = anchor.dy + 10;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, width, height),
      const Radius.circular(12),
    );

    canvas.drawRRect(
      rect,
      Paint()..color = const Color(0xFF102235),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = AppColors.primaryLight.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    textPainter.paint(
      canvas,
      Offset(left + horizontalPadding, top + verticalPadding),
    );
  }

  void _paintText({
    required Canvas canvas,
    required String text,
    required double x,
    required double y,
    required double maxWidth,
    required Color color,
    required double fontSize,
    TextAlign textAlign = TextAlign.left,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);

    var paintX = x;

    if (textAlign == TextAlign.center) {
      paintX = x + (maxWidth - textPainter.width) / 2;
    } else if (textAlign == TextAlign.right) {
      paintX = x + maxWidth - textPainter.width;
    }

    textPainter.paint(canvas, Offset(paintX, y));
  }

  String _formatPriceAxisValue(double value) {
    if (value.abs() < 0.1) {
      return value.toStringAsFixed(3).replaceAll('.', ',');
    }

    if (value.abs() < 1) {
      return value.toStringAsFixed(2).replaceAll('.', ',');
    }

    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _formatSelectedPriceValue(double value) {
    if (value.abs() < 0.1) {
      return value.toStringAsFixed(3).replaceAll('.', ',');
    }

    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  bool shouldRepaint(covariant _StartupLineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.labels != labels ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
