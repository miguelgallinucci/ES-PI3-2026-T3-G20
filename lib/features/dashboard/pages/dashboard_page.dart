import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final periods = ['Diário', 'Semanal', 'Mensal', '6 meses', 'YTD'];

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
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Acompanhe o desempenho da sua carteira e a valorização dos seus investimentos.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: periods
                          .map(
                            (period) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: period == 'Mensal'
                                ? AppColors.primary.withValues(alpha: 0.16)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            period,
                            style: TextStyle(
                              color: period == 'Mensal'
                                  ? AppColors.primaryLight
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Valorização da carteira',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '+13,4% no período',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 220,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: const [
                                _Bar(heightFactor: 0.30, label: 'Jan'),
                                _Bar(heightFactor: 0.42, label: 'Fev'),
                                _Bar(heightFactor: 0.38, label: 'Mar'),
                                _Bar(heightFactor: 0.58, label: 'Abr'),
                                _Bar(heightFactor: 0.74, label: 'Mai'),
                                _Bar(heightFactor: 0.88, label: 'Jun'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: const [
                        Expanded(
                          child: _MetricCard(
                            label: 'Valor atual',
                            value: 'R\$ 14.180',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Rentabilidade',
                            value: '+13,4%',
                            highlight: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: const [
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

class _Bar extends StatelessWidget {
  final double heightFactor;
  final String label;

  const _Bar({
    required this.heightFactor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 170 * heightFactor,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
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