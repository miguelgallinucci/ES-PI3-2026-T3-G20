// Widget responsável por exibir a variação de desempenho no dashboard.
//
// Isola a badge de tendência positiva ou negativa, mantendo a DashboardPage
// focada nos cálculos e na organização geral da tela.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DashboardTrendBadge extends StatelessWidget {
  final double value;
  final bool isPositive;

  const DashboardTrendBadge({
    super.key,
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
