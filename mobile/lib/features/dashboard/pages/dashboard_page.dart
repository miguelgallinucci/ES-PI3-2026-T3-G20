import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF04111D),
              Color(0xFF071A2B),
              Color(0xFF0A2235),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Desempenho da carteira',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Acompanhe a evolucao dos seus investimentos por periodo, com valores e pontos de referencia no grafico.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _DashboardPeriodSelector(
                      selectedPeriod: _selectedPeriod,
                      onPeriodChanged: (period) {
                        setState(() {
                          _selectedPeriod = period;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Container(
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
                                  'Evolucao do patrimonio',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _TrendBadge(
                                value: variation,
                                isPositive: isPositive,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}% $_periodLabel',
                            style: TextStyle(
                              color: isPositive
                                  ? AppColors.primaryLight
                                  : Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Atual: R\$ ${_formatCurrency(currentValue)}',
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
                          child: _MetricCard(
                            label: 'Valor atual',
                            value: 'R\$ ${_formatCurrency(currentValue)}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Rentabilidade',
                            value:
                                '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}%',
                            highlight: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Melhor ativo',
                            value: 'GreenVolt',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Startups',
                            value: '3',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Maior alta',
                            value: '+21,5%',
                            highlight: true,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Aporte total',
                            value: 'R\$ 12.500',
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
      ),
    );
  }
}

class _DashboardPeriodSelector extends StatelessWidget {
  final DashboardPeriod selectedPeriod;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  const _DashboardPeriodSelector({
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
        children: const [
          _DashboardPeriodButton(label: 'Dia', period: DashboardPeriod.day),
          _DashboardPeriodButton(label: 'Semana', period: DashboardPeriod.week),
          _DashboardPeriodButton(label: 'Mes', period: DashboardPeriod.month),
          _DashboardPeriodButton(label: '6M', period: DashboardPeriod.sixMonths),
          _DashboardPeriodButton(label: 'Ano', period: DashboardPeriod.year),
        ].map((button) {
          return Expanded(
            child: _DashboardPeriodButtonHost(
              button: button,
              selectedPeriod: selectedPeriod,
              onPeriodChanged: onPeriodChanged,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DashboardPeriodButtonHost extends StatelessWidget {
  final _DashboardPeriodButton button;
  final DashboardPeriod selectedPeriod;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  const _DashboardPeriodButtonHost({
    required this.button,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedPeriod == button.period;

    return GestureDetector(
      onTap: () => onPeriodChanged(button.period),
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
          button.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DashboardPeriodButton {
  final String label;
  final DashboardPeriod period;

  const _DashboardPeriodButton({
    required this.label,
    required this.period,
  });
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
              valueFormatter: _formatCompactCurrency,
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

class _TrendBadge extends StatelessWidget {
  final double value;
  final bool isPositive;

  const _TrendBadge({
    required this.value,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: (isPositive ? AppColors.primary : Colors.redAccent)
            .withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: isPositive ? AppColors.primaryLight : Colors.redAccent,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}${value.toStringAsFixed(1)}%',
            style: TextStyle(
              color: isPositive ? AppColors.primaryLight : Colors.redAccent,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _MetricCard({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: highlight ? AppColors.primaryLight : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double value) {
  return value
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );
}

String _formatCompactCurrency(double value) {
  if (value.abs() >= 1000) {
    final compact = value / 1000;
    return '${compact.toStringAsFixed(1).replaceAll('.', ',')}k';
  }

  return value.toStringAsFixed(0);
}
