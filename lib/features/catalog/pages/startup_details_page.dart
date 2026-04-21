import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'investment_page.dart';

class StartupDetailsPage extends StatelessWidget {
  final String name;
  final String sector;
  final String stage;
  final String description;
  final String capital;
  final String tokens;

  const StartupDetailsPage({
    super.key,
    required this.name,
    required this.sector,
    required this.stage,
    required this.description,
    required this.capital,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    const chartValues = [8.2, 8.9, 8.6, 9.4, 10.8, 12.5];
    final currentPrice = chartValues.last;
    final firstPrice = chartValues.first;
    final variation = ((currentPrice - firstPrice) / firstPrice) * 100;
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            sector,
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          stage,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
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
                                  'Movimentação do token',
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
                                  color: (isPositive
                                      ? AppColors.primary
                                      : Colors.redAccent)
                                      .withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: isPositive
                                        ? AppColors.primaryLight
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Últimos 6 meses',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  label: 'Preço atual',
                                  value: 'R\$ ${currentPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                                  highlight: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InfoCard(
                                  label: 'Variação',
                                  value:
                                  '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}%',
                                  highlight: isPositive,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          const SizedBox(
                            height: 190,
                            child: _StartupLineChart(
                              values: chartValues,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _AxisLabel(text: 'Jan'),
                              _AxisLabel(text: 'Fev'),
                              _AxisLabel(text: 'Mar'),
                              _AxisLabel(text: 'Abr'),
                              _AxisLabel(text: 'Mai'),
                              _AxisLabel(text: 'Jun'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            label: 'Capital aportado',
                            value: capital,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            label: 'Tokens emitidos',
                            value: tokens,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _SectionCard(
                      title: 'Sumário executivo',
                      child: const Text(
                        'Esta startup atua com foco em inovação tecnológica, crescimento sustentável e geração de valor para o ecossistema. A proposta busca resolver dores reais do mercado com apoio de tecnologia, dados e escalabilidade.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    _SectionCard(
                      title: 'Estrutura societária',
                      child: const Column(
                        children: [
                          _MemberRow(
                            name: 'Ana Martins',
                            role: 'CEO',
                            value: '45%',
                          ),
                          SizedBox(height: 12),
                          _MemberRow(
                            name: 'Lucas Ferreira',
                            role: 'CTO',
                            value: '35%',
                          ),
                          SizedBox(height: 12),
                          _MemberRow(
                            name: 'Marina Souza',
                            role: 'COO',
                            value: '20%',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _SectionCard(
                      title: 'Mentores e conselho',
                      child: const Column(
                        children: [
                          _MemberRow(
                            name: 'Carlos Almeida',
                            role: 'Mentor em Estratégia',
                          ),
                          SizedBox(height: 12),
                          _MemberRow(
                            name: 'Fernanda Lima',
                            role: 'Conselho Consultivo',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _SectionCard(
                      title: 'Perguntas públicas',
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _QuestionItem(
                            question: 'Qual o principal diferencial da startup?',
                            answer:
                            'O diferencial está na integração entre tecnologia, escalabilidade e foco em eficiência operacional.',
                          ),
                          SizedBox(height: 14),
                          _QuestionItem(
                            question: 'Em que estágio a operação se encontra?',
                            answer:
                            'A startup já possui operação estruturada e está em fase de crescimento dentro do ecossistema.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _SectionCard(
                      title: 'Vídeo demonstrativo',
                      child: Container(
                        height: 170,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_fill_rounded,
                                color: AppColors.primaryLight,
                                size: 52,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Área reservada para vídeo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InvestmentPage(
                                startupName: name,
                                sector: sector,
                                tokenPrice:
                                'R\$ ${currentPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                                availableBalance: 'R\$ 5.000,00',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Investir nesta startup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

class _StartupLineChart extends StatelessWidget {
  final List<double> values;

  const _StartupLineChart({
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StartupLineChartPainter(values),
      child: Container(),
    );
  }
}

class _StartupLineChartPainter extends CustomPainter {
  final List<double> values;

  _StartupLineChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 4
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
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue) == 0 ? 1.0 : (maxValue - minValue);

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = (size.width / (values.length - 1)) * i;
      final normalized = (values[i] - minValue) / range;
      final y = size.height - (normalized * (size.height - 18)) - 10;
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    for (final point in points) {
      canvas.drawCircle(
        point,
        9,
        Paint()..color = AppColors.primary.withValues(alpha: 0.18),
      );
      canvas.drawCircle(point, 5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AxisLabel extends StatelessWidget {
  final String text;

  const _AxisLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoCard({
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
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppColors.primaryLight : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final String name;
  final String role;
  final String? value;

  const _MemberRow({
    required this.name,
    required this.role,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuestionItem extends StatelessWidget {
  final String question;
  final String answer;

  const _QuestionItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}