//carteira

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/investment_card.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Meus investimentos',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Acompanhe sua carteira, desempenho e movimentação das startups em que você investe.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
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
                            'Resumo da carteira',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: const [
                              Expanded(
                                child: _SummaryCard(
                                  label: 'Total investido',
                                  value: 'R\$ 12.500',
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _SummaryCard(
                                  label: 'Valor atual',
                                  value: 'R\$ 14.180',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: const [
                              Expanded(
                                child: _SummaryCard(
                                  label: 'Rentabilidade',
                                  value: '+13,4%',
                                  isHighlight: true,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _SummaryCard(
                                  label: 'Startups',
                                  value: '3',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      'Sua carteira',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const InvestmentCard(
                      name: 'VisionAI Health',
                      sector: 'Saúde',
                      amountInvested: 'R\$ 5.000',
                      currentValue: 'R\$ 5.720',
                      performance: '+14,4%',
                      isPositive: true,
                    ),

                    const InvestmentCard(
                      name: 'GreenVolt Hub',
                      sector: 'Energia',
                      amountInvested: 'R\$ 4.000',
                      currentValue: 'R\$ 4.860',
                      performance: '+21,5%',
                      isPositive: true,
                    ),

                    const InvestmentCard(
                      name: 'AgroLink Data',
                      sector: 'Agrotech',
                      amountInvested: 'R\$ 3.500',
                      currentValue: 'R\$ 3.600',
                      performance: '+2,8%',
                      isPositive: true,
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

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _SummaryCard({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(22),
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
              color: isHighlight ? AppColors.primaryLight : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}