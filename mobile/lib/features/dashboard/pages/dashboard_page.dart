import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../shared/widgets/app_metric_card.dart';
import '../widgets/dashboard_period_selector.dart';
import '../widgets/dashboard_trend_badge.dart';
import '../../../core/utils/app_formatters.dart';

enum DashboardPeriod {
  day,
  week,
  month,
  sixMonths,
  year,
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardPeriod _selectedPeriod = DashboardPeriod.month;

  List<double> get _walletValues {
    switch (_selectedPeriod) {
      case DashboardPeriod.day:
        return const [13880, 13920, 13905, 14040, 14010, 14120, 14180];
      case DashboardPeriod.week:
        return const [13280, 13510, 13460, 13720, 13890, 14060, 14180];
      case DashboardPeriod.month:
        return const [12500, 12860, 13140, 13420, 13810, 14180];
      case DashboardPeriod.sixMonths:
        return const [11200, 11640, 12150, 12500, 13240, 14180];
      case DashboardPeriod.year:
        return const [
          9800,
          10120,
          10650,
          10980,
          11200,
          11640,
          12150,
          12500,
          12940,
          13240,
          13710,
          14180,
        ];
    }
  }

  List<String> get _walletLabels {
    switch (_selectedPeriod) {
      case DashboardPeriod.day:
        return const ['00h', '04h', '08h', '12h', '16h', '20h', '24h'];
      case DashboardPeriod.week:
        return const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
      case DashboardPeriod.month:
        return const ['1', '7', '14', '21', '28', 'Hoje'];
      case DashboardPeriod.sixMonths:
        return const ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
      case DashboardPeriod.year:
        return const [
          'Jan',
          'Fev',
          'Mar',
          'Abr',
          'Mai',
          'Jun',
          'Jul',
          'Ago',
          'Set',
          'Out',
          'Nov',
          'Dez',
        ];
    }
  }

  String get _periodLabel {
    switch (_selectedPeriod) {
      case DashboardPeriod.day:
        return 'no dia';
      case DashboardPeriod.week:
        return 'na semana';
      case DashboardPeriod.month:
        return 'no mes';
      case DashboardPeriod.sixMonths:
        return 'em 6 meses';
      case DashboardPeriod.year:
        return 'no ano';
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = _walletValues;
    final labels = _walletLabels;
    final currentValue = values.last;
    final firstValue = values.first;
    final variation = ((currentValue - firstValue) / firstValue) * 100;
    final isPositive = variation >= 0;

    return Scaffold(
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Desempenho da carteira',
                    subtitle:
                        'Acompanhe a evolucao dos seus investimentos por periodo, com valores e pontos de referencia no grafico.',
                    onBack: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 22),
                  DashboardPeriodSelector(
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: (period) {
                      setState(() {
                        _selectedPeriod = period;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  AppSectionCard(
                    title: 'Evolucao do patrimonio',
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}% $_periodLabel',
                                style: TextStyle(
                                  color: isPositive
                                      ? AppColors.primaryLight
                                      : Colors.redAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            DashboardTrendBadge(
                               value: variation,
                               isPositive: isPositive,
                             ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Atual: ${AppFormatters.currency(currentValue)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 260,
                          child: WalletLineChart(
                            values: values,
                            labels: labels,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: AppMetricCard(
                          label: 'Valor atual',
                          value: AppFormatters.currency(currentValue),
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppMetricCard(
                          label: 'Rentabilidade',
                          value:
                              '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}%',
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: AppMetricCard(
                          label: 'Melhor ativo',
                          value: 'GreenVolt',
                          icon: Icons.star_rounded,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: AppMetricCard(
                          label: 'Startups',
                          value: '3',
                          icon: Icons.business_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: AppMetricCard(
                          label: 'Maior alta',
                          value: '+21,5%',
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: AppMetricCard(
                          label: 'Aporte total',
                          value: 'R\$ 12.500',
                          icon: Icons.savings_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class WalletLineChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;

  const WalletLineChart({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  State<WalletLineChart> createState() => _WalletLineChartState();
}

class _WalletLineChartState extends State<WalletLineChart> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant WalletLineChart oldWidget) {
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

    const leftPadding = 58.0;
    const rightPadding = 18.0;
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
            painter: _ReadableLineChartPainter(
              values: widget.values,
              labels: widget.labels,
              selectedIndex: _selectedIndex,
              valuePrefix: 'R\$ ',
              valueFormatter: AppFormatters.compactCurrency,
            ),
            child: Container(),
          ),
        );
      },
    );
  }
}

class _ReadableLineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final int? selectedIndex;
  final String valuePrefix;
  final String Function(double value) valueFormatter;

  _ReadableLineChartPainter({
    required this.values,
    required this.labels,
    required this.selectedIndex,
    required this.valuePrefix,
    required this.valueFormatter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || labels.isEmpty) return;

    final itemCount = values.length < labels.length ? values.length : labels.length;
    if (itemCount == 0) return;

    final visibleValues = values.take(itemCount).toList();
    final minValue = visibleValues.reduce((a, b) => a < b ? a : b);
    final maxValue = visibleValues.reduce((a, b) => a > b ? a : b);
    final rawRange = maxValue - minValue;
    final padding = rawRange == 0 ? maxValue.abs() * 0.08 : rawRange * 0.16;
    final chartMin = minValue - padding;
    final chartMax = maxValue + padding;
    final range = chartMax - chartMin == 0 ? 1.0 : chartMax - chartMin;

    const leftPadding = 58.0;
    const rightPadding = 18.0;
    const topPadding = 16.0;
    const bottomPadding = 34.0;
    final chartHeight = size.height - topPadding - bottomPadding;
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
          Color(0x4434D399),
          Color(0x0034D399),
        ],
      ).createShader(
        Rect.fromLTWH(leftPadding, topPadding, availableWidth, chartHeight),
      );

    final chartBottom = topPadding + chartHeight;

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
        text: '$valuePrefix${valueFormatter(value)}',
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
      canvas.drawCircle(
        point,
        isActive ? 8 : 6,
        Paint()..color = AppColors.primary.withValues(alpha: 0.18),
      );
      canvas.drawCircle(
        point,
        isActive ? 5.2 : 4.4,
        Paint()..color = const Color(0xFF04111D),
      );
      canvas.drawCircle(
        point,
        isActive ? 3.8 : 3,
        Paint()..color = AppColors.primaryLight,
      );
    }

    _paintValueBubble(
      canvas: canvas,
      text: '${labels[activeIndex]}  $valuePrefix${valueFormatter(values[activeIndex])}',
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
      final labelX = (point.dx - labelWidth / 2)
          .clamp(0.0, size.width - labelWidth);

      _paintText(
        canvas: canvas,
        text: label,
        x: labelX,
        y: chartBottom + 12,
        maxWidth: labelWidth,
        color: i == activeIndex ? AppColors.primaryLight : AppColors.textSecondary,
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

  @override
  bool shouldRepaint(covariant _ReadableLineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.labels != labels ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.valuePrefix != valuePrefix;
  }
}
