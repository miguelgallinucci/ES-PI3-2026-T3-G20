// Widget responsável por exibir uma posição de tokens do usuário no balcão.
//
// Isola o card visual usado na aba de venda da CatalogPage, mantendo
// a interface pronta para futura integração com dados reais.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'catalog_startup_card.dart'; // Para o StartupLogo
import 'catalog_market_offer_card.dart'; // Para o MiniInfo

class UserTokenPosition {
  final String startup;
  final String sector;
  final int tokensOwned;
  final double currentPrice;
  final String variation;

  const UserTokenPosition({
    required this.startup,
    required this.sector,
    required this.tokensOwned,
    required this.currentPrice,
    required this.variation,
  });
}

class CatalogUserPositionCard extends StatelessWidget {
  final UserTokenPosition position;
  final String Function(double value) formatCurrency;
  final VoidCallback onSell;

  const CatalogUserPositionCard({
    super.key,
    required this.position,
    required this.formatCurrency,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final estimatedValue = position.tokensOwned * position.currentPrice;
    final isPositive = !position.variation.startsWith('-');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StartupLogo(name: position.startup),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position.startup,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      position.sector,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                position.variation,
                style: TextStyle(
                  color: isPositive
                      ? AppColors.primaryLight
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MiniInfo(
                  label: 'Você possui',
                  value: '${position.tokensOwned} tokens',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MiniInfo(
                  label: 'Preço atual',
                  value: formatCurrency(position.currentPrice),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MiniInfo(
                  label: 'Estimado',
                  value: formatCurrency(estimatedValue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: onSell,
              icon: const Icon(Icons.sell_rounded, size: 20),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryLight,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.55),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              label: const Text(
                'Criar oferta de venda',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: highlight ? AppColors.primaryLight : Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
