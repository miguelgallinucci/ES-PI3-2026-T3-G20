// Widget responsável por exibir o resumo financeiro da carteira.
//
// Centraliza saldo disponível, total investido, startups e ação de aporte,
// mantendo a WalletPage focada na leitura dos dados e na orquestração.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WalletSummarySection extends StatelessWidget {
  final String availableBalance;
  final String totalInvested;
  final String startupsCount;
  final VoidCallback onAddBalance;

  const WalletSummarySection({
    super.key,
    required this.availableBalance,
    required this.totalInvested,
    required this.startupsCount,
    required this.onAddBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
                  'Resumo da carteira',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onAddBalance,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Adicionar saldo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: _SummaryCard(
              label: 'Saldo disponível',
              value: availableBalance,
              isHighlight: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total investido',
                  value: totalInvested,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Startups',
                  value: startupsCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget auxiliar que exibe resumo da carteira com label e valor.
/// Mantido privado dentro da seção de resumo por ter design específico (sem ícone e com destaque).
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
        border: Border.all(
          color: isHighlight
              ? AppColors.primary.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.04),
        ),
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
