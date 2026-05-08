// Widget Card de Investimento
//
// Exibe as informações de um investimento individual em formato de card,
// incluindo:
// - Nome e setor do investimento
// - Valor investido e valor atual
// - Performance/retorno do investimento
// - Indicação visual se a performance é positiva ou negativa

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget que exibe as informações de um investimento em formato de card
class WalletInvestmentCard extends StatelessWidget {
  /// Nome do investimento/ativo
  final String name;
  /// Setor de atuação do investimento
  final String sector;
  /// Valor investido inicialmente (formatado em moeda)
  final String amountInvested;
  /// Valor atual do investimento (formatado em moeda)
  final String currentValue;
  /// Texto de performance/retorno (ex: "+5.2%")
  final String performance;
  /// Indica se a performance é positiva (true) ou negativa (false)
  final bool isPositive;

  /// Construtor do card de investimento
  /// Todos os parâmetros são obrigatórios
  const WalletInvestmentCard({
    super.key,
    required this.name,
    required this.sector,
    required this.amountInvested,
    required this.currentValue,
    required this.performance,
    required this.isPositive,
  });

  /// Constrói a interface do card com layout em coluna
  /// Exibe seção superior com setor e performance
  /// E seção inferior com nome do investimento
  /// E seção de valores com investido e valor atual
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                performance,
                style: TextStyle(
                  color: isPositive ? AppColors.primaryLight : Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'Investido',
                  value: amountInvested,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoItem(
                  label: 'Valor atual',
                  value: currentValue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget auxiliar para exibir um item de informação (label + valor)
/// Utilizado para mostrar valores de investido e valor atual
class _InfoItem extends StatelessWidget {
  /// Rótulo/label da informação (ex: "Investido")
  final String label;
  /// Valor a ser exibido (formatado)
  final String value;

  /// Construtor com parâmetros obrigatórios
  const _InfoItem({
    required this.label,
    required this.value,
  });

  /// Constrói o widget com label acima do valor
  /// Layout em coluna com espaçamento e estilos apropriados
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
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
