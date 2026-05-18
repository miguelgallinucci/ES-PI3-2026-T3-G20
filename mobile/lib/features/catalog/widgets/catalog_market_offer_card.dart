// Widget responsável por exibir uma oferta disponível no balcão de negociações.
//
// Isola o card visual de compra usado na CatalogPage, mantendo o balcão
// organizado enquanto os dados ainda são mockados.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'catalog_startup_card.dart'; // Para o StartupLogo

class AvailableOffer {
  final String startup;
  final String sector;
  final String stage;
  final int quantity;
  final double unitPrice;
  final String variation;

  const AvailableOffer({
    required this.startup,
    required this.sector,
    required this.stage,
    required this.quantity,
    required this.unitPrice,
    required this.variation,
  });
}

class CatalogMarketOfferCard extends StatelessWidget {
  final AvailableOffer offer;
  final String Function(double value) formatCurrency;
  final VoidCallback onBuy;

  const CatalogMarketOfferCard({
    super.key,
    required this.offer,
    required this.formatCurrency,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final total = offer.quantity * offer.unitPrice;
    final isPositive = !offer.variation.startsWith('-');

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
              StartupLogo(name: offer.startup),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.startup,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${offer.sector} • ${offer.stage}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  offer.variation,
                  style: TextStyle(
                    color: isPositive
                        ? AppColors.primaryLight
                        : AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MiniInfo(
                  label: 'Quantidade',
                  value: '${offer.quantity} tokens',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MiniInfo(
                  label: 'Preço/token',
                  value: formatCurrency(offer.unitPrice),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MiniInfo(label: 'Total', value: formatCurrency(total)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onBuy,
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              label: const Text(
                'Comprar esta oferta',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MiniInfo extends StatelessWidget {
  final String label;
  final String value;

  const MiniInfo({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
