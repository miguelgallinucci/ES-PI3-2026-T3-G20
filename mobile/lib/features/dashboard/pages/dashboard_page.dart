import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../shared/widgets/app_metric_card.dart';
import '../widgets/dashboard_period_selector.dart';
import '../widgets/dashboard_trend_badge.dart';
import '../../../core/utils/app_formatters.dart';
import '../../wallet/services/wallet_service.dart';

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
  final WalletService _walletService = WalletService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DashboardPeriod _selectedPeriod = DashboardPeriod.month;

  Stream<QuerySnapshot<Map<String, dynamic>>> _watchStartups() {
    return _firestore.collection('startups').snapshots();
  }

  /// desenvolvido por Miguel Gallinucci - calcula os indicadores reais de investimentos.
  _DashboardData _buildDashboardData(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> transactionDocs,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> startupDocs,
  ) {
    final startupPrices = <String, double>{};
    final startupVariations = <String, double>{};

    for (final doc in startupDocs) {
      final data = doc.data();
      startupPrices[doc.id] = _toDouble(data['tokenPrice']);
      startupVariations[doc.id] = _toDouble(data['variationPercent']);
    }

    final positions = _positionsFromTransactions(transactionDocs);
    final currentPositions = positions.map((position) {
      final currentPrice = startupPrices[position.startupId] ?? 0;

      return position.copyWith(
        currentPrice: currentPrice > 0 ? currentPrice : position.currentPrice,
      );
    }).toList();

    final currentValue = currentPositions.fold<double>(
      0,
      (total, position) => total + position.currentValue,
    );
    final totalInvested = currentPositions.fold<double>(
      0,
      (total, position) => total + position.totalInvested,
    );
    final variation = totalInvested > 0
        ? ((currentValue - totalInvested) / totalInvested) * 100
        : 0.0;
    final bestPosition = currentPositions.isEmpty
        ? null
        : currentPositions.reduce((best, position) {
            return position.returnPercent > best.returnPercent
                ? position
                : best;
          });
    final biggestVariation = currentPositions.fold<double>(0, (value, position) {
      final startupVariation = startupVariations[position.startupId] ?? 0;
      return startupVariation > value ? startupVariation : value;
    });
    final chartData = _buildWalletChartData(transactionDocs, currentValue);

    return _DashboardData(
      currentValue: currentValue,
      totalInvested: totalInvested,
      variation: variation,
      startupsCount: currentPositions.length,
      bestAsset: bestPosition?.startupName ?? '-',
      biggestVariation: biggestVariation,
      chartValues: chartData.values,
      chartLabels: chartData.labels,
    );
  }

  /// desenvolvido por Miguel Gallinucci - reconstrui as posicoes do dashboard por transacoes.
  List<_DashboardPosition> _positionsFromTransactions(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final positions = <String, _DashboardPosition>{};
    final orderedDocs = [...docs]
      ..sort((a, b) {
        final aDate = _toMillis(a.data()['createdAt']);
        final bDate = _toMillis(b.data()['createdAt']);

        return aDate.compareTo(bDate);
      });

    for (final doc in orderedDocs) {
      final data = doc.data();
      final type = (data['type'] ?? data['tipo'] ?? '')
          .toString()
          .toLowerCase();
      final isPurchase = type == 'compra' || type == 'compra_balcao';
      final isReservedForSale = type == 'oferta_venda';
      final isCanceledOffer = type == 'cancelamento_oferta';

      if (!isPurchase && !isReservedForSale && !isCanceledOffer) {
        continue;
      }

      final startupName = (data['startupName'] ??
              data['nomeStartup'] ??
              data['startup'] ??
              'Startup')
          .toString();
      final startupId = (data['startupId'] ?? startupName).toString();
      final quantity = _toInt(data['quantity']);
      final tokenPrice = _toDouble(data['tokenPrice']);
      final totalValue = _toDouble(
        data['totalValue'] ?? data['valorTotal'] ?? data['amount'],
      ).abs();
      final reservedCost = _toDouble(data['reservedCost']);

      if (quantity <= 0) continue;

      final current = positions[startupId];
      var newQuantity = current?.quantity ?? 0;
      var newTotalInvested = current?.totalInvested ?? 0;
      var newCurrentPrice = current?.currentPrice ?? 0;

      if (isPurchase) {
        newQuantity += quantity;
        newTotalInvested += totalValue;
        newCurrentPrice = tokenPrice > 0 ? tokenPrice : newCurrentPrice;
      } else if (isReservedForSale) {
        final averagePrice =
            newQuantity > 0 ? newTotalInvested / newQuantity : 0;
        final costToRemove = reservedCost > 0
            ? reservedCost
            : averagePrice * quantity;

        newQuantity -= quantity;
        newTotalInvested -= costToRemove;

        if (newQuantity < 0) newQuantity = 0;
        if (newTotalInvested < 0) newTotalInvested = 0;
      } else if (isCanceledOffer) {
        newQuantity += quantity;
        newTotalInvested += reservedCost;
      }

      positions[startupId] = _DashboardPosition(
        startupId: startupId,
        startupName: startupName,
        quantity: newQuantity,
        totalInvested: newTotalInvested,
        currentPrice: newCurrentPrice,
      );
    }

    return positions.values.where((position) => position.quantity > 0).toList();
  }

  /// desenvolvido por Miguel Gallinucci - monta o grafico de patrimonio pelo periodo escolhido.
  _ChartData _buildWalletChartData(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    double currentValue,
  ) {
    final cutoff = DateTime.now().subtract(_selectedPeriodDuration);
    final orderedDocs = [...docs]
      ..sort((a, b) {
        final aDate = _toMillis(a.data()['createdAt']);
        final bDate = _toMillis(b.data()['createdAt']);

        return aDate.compareTo(bDate);
      });
    final values = <double>[];
    final labels = <String>[];
    var runningValue = 0.0;

    for (final doc in orderedDocs) {
      final data = doc.data();
      final createdAt = _toDateTime(data['createdAt']);
      final type = (data['type'] ?? data['tipo'] ?? '')
          .toString()
          .toLowerCase();
      final isPurchase = type == 'compra' || type == 'compra_balcao';
      final isReservedForSale = type == 'oferta_venda';
      final isCanceledOffer = type == 'cancelamento_oferta';

      if (!isPurchase && !isReservedForSale && !isCanceledOffer) continue;

      final totalValue = _toDouble(
        data['totalValue'] ?? data['valorTotal'] ?? data['amount'],
      ).abs();
      final reservedCost = _toDouble(data['reservedCost']);

      if (isPurchase || isCanceledOffer) {
        runningValue += isCanceledOffer ? reservedCost : totalValue;
      } else if (isReservedForSale) {
        runningValue -= reservedCost > 0 ? reservedCost : totalValue;
      }

      if (runningValue < 0) runningValue = 0;

      if (createdAt == null ||
          createdAt.isBefore(cutoff) ||
          runningValue <= 0) {
        continue;
      }

      values.add(runningValue);
      labels.add(_formatChartLabel(createdAt));
    }

    if (currentValue > 0) {
      values.add(currentValue);
      labels.add('Hoje');
    }

    if (values.isEmpty) {
      return const _ChartData(values: [0], labels: ['Hoje']);
    }

    if (values.length == 1) {
      values.insert(0, 0);
      labels.insert(0, 'Inicio');
    }

    return _ChartData(values: values, labels: labels);
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(
            value
                .replaceAll('R\$', '')
                .replaceAll(' ', '')
                .replaceAll('.', '')
                .replaceAll(',', '.'),
          ) ??
          0;
    }

    return 0;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }

  int _toMillis(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;

    return 0;
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    return null;
  }

  Duration get _selectedPeriodDuration {
    switch (_selectedPeriod) {
      case DashboardPeriod.day:
        return const Duration(hours: 24);
      case DashboardPeriod.week:
        return const Duration(days: 7);
      case DashboardPeriod.month:
        return const Duration(days: 30);
      case DashboardPeriod.sixMonths:
        return const Duration(days: 183);
      case DashboardPeriod.year:
        return const Duration(days: 365);
    }
  }

  String _formatChartLabel(DateTime date) {
    switch (_selectedPeriod) {
      case DashboardPeriod.day:
        return '${date.hour.toString().padLeft(2, '0')}h';
      case DashboardPeriod.week:
      case DashboardPeriod.month:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      case DashboardPeriod.sixMonths:
      case DashboardPeriod.year:
        return '${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
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
    return Scaffold(
      body: AppBackground(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _walletService.watchUserTransactions(),
          builder: (context, transactionsSnapshot) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _watchStartups(),
              builder: (context, startupsSnapshot) {
                final dashboardData = _buildDashboardData(
                  transactionsSnapshot.data?.docs ?? [],
                  startupsSnapshot.data?.docs ?? [],
                );
                final isPositive = dashboardData.variation >= 0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PageHeader(
                            title: 'Meus investimentos',
                            subtitle:
                                'Acompanhe a evolucao real da sua carteira.',
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
                                        '${isPositive ? '+' : ''}${dashboardData.variation.toStringAsFixed(1)}% $_periodLabel',
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
                                      value: dashboardData.variation,
                                      isPositive: isPositive,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Atual: ${AppFormatters.currency(dashboardData.currentValue)}',
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
                                    values: dashboardData.chartValues,
                                    labels: dashboardData.chartLabels,
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
                                  value: AppFormatters.currency(
                                    dashboardData.currentValue,
                                  ),
                                  icon: Icons.account_balance_wallet_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppMetricCard(
                                  label: 'Rentabilidade',
                                  value:
                                      '${isPositive ? '+' : ''}${dashboardData.variation.toStringAsFixed(1)}%',
                                  icon: Icons.trending_up_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppMetricCard(
                                  label: 'Melhor ativo',
                                  value: dashboardData.bestAsset,
                                  icon: Icons.star_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppMetricCard(
                                  label: 'Startups',
                                  value: dashboardData.startupsCount.toString(),
                                  icon: Icons.business_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppMetricCard(
                                  label: 'Maior alta',
                                  value:
                                      '+${dashboardData.biggestVariation.toStringAsFixed(1)}%',
                                  icon: Icons.arrow_upward_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppMetricCard(
                                  label: 'Aporte total',
                                  value: AppFormatters.currency(
                                    dashboardData.totalInvested,
                                  ),
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DashboardPosition {
  final String startupId;
  final String startupName;
  final int quantity;
  final double totalInvested;
  final double currentPrice;

  const _DashboardPosition({
    required this.startupId,
    required this.startupName,
    required this.quantity,
    required this.totalInvested,
    required this.currentPrice,
  });

  double get currentValue => quantity * currentPrice;

  double get returnPercent {
    if (totalInvested <= 0) return 0;

    return ((currentValue - totalInvested) / totalInvested) * 100;
  }

  _DashboardPosition copyWith({
    double? currentPrice,
  }) {
    return _DashboardPosition(
      startupId: startupId,
      startupName: startupName,
      quantity: quantity,
      totalInvested: totalInvested,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }
}

class _DashboardData {
  final double currentValue;
  final double totalInvested;
  final double variation;
  final int startupsCount;
  final String bestAsset;
  final double biggestVariation;
  final List<double> chartValues;
  final List<String> chartLabels;

  const _DashboardData({
    required this.currentValue,
    required this.totalInvested,
    required this.variation,
    required this.startupsCount,
    required this.bestAsset,
    required this.biggestVariation,
    required this.chartValues,
    required this.chartLabels,
  });
}

class _ChartData {
  final List<double> values;
  final List<String> labels;

  const _ChartData({
    required this.values,
    required this.labels,
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
