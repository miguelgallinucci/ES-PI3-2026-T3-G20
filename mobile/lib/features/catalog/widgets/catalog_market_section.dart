// Widget responsável por exibir a área do balcão de negociações no catálogo.
//
// Mantém a CatalogPage como orquestradora, mas isola a interface de compra
// e venda simulada de tokens em um componente próprio.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'catalog_market_offer_card.dart';
import 'catalog_user_position_card.dart';

class CatalogMarketSection extends StatelessWidget {
  final bool isBuySelected;
  final ValueChanged<bool> onModeChanged;
  final List<AvailableOffer> availableOffers;
  final List<UserTokenPosition> userPositions;
  final int totalTokensInWallet;
  final double estimatedWalletValue;
  final String Function(double value) formatCurrency;
  final Function(AvailableOffer offer) onBuyOffer;
  final Function(UserTokenPosition position) onSellPosition;

  const CatalogMarketSection({
    super.key,
    required this.isBuySelected,
    required this.onModeChanged,
    required this.availableOffers,
    required this.userPositions,
    required this.totalTokensInWallet,
    required this.estimatedWalletValue,
    required this.formatCurrency,
    required this.onBuyOffer,
    required this.onSellPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('market-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _ModeButton(
                icon: Icons.add_shopping_cart_rounded,
                text: 'Comprar',
                selected: isBuySelected,
                onTap: () => onModeChanged(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModeButton(
                icon: Icons.sell_rounded,
                text: 'Vender',
                selected: !isBuySelected,
                onTap: () => onModeChanged(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        isBuySelected ? _buildBuyMarketContent() : _buildSellMarketContent(),
      ],
    );
  }

  Widget _buildBuyMarketContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: _MarketInfoCard(
                label: 'Saldo',
                value: 'R\$ 5.000,00',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MarketInfoCard(
                label: 'Ofertas abertas',
                value: availableOffers.length.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Ofertas disponíveis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Escolha uma oferta para comprar tokens de uma startup.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        ...availableOffers.map(
          (offer) => CatalogMarketOfferCard(
            offer: offer,
            formatCurrency: formatCurrency,
            onBuy: () => onBuyOffer(offer),
          ),
        ),
      ],
    );
  }

  Widget _buildSellMarketContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MarketInfoCard(
                label: 'Tokens na carteira',
                value: totalTokensInWallet.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MarketInfoCard(
                label: 'Valor estimado',
                value: formatCurrency(estimatedWalletValue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Meus tokens',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Selecione uma startup da sua carteira para criar uma oferta de venda.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        ...userPositions.map(
          (position) => CatalogUserPositionCard(
            position: position,
            formatCurrency: formatCurrency,
            onSell: () => onSellPosition(position),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: selected
            ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.55)
                    : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: selected ? AppColors.primaryLight : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? AppColors.primaryLight : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketInfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _MarketInfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
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
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
