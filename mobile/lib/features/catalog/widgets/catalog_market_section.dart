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
  final List<AvailableOffer> userOffers;
  final List<UserTokenPosition> userPositions;
  final double availableBalance;
  final int totalTokensInWallet;
  final String buyOfferSort;
  final ValueChanged<String> onBuyOfferSortChanged;
  final String Function(double value) formatCurrency;
  final Function(AvailableOffer offer) onBuyOffer;
  final Function(AvailableOffer offer) onCancelOffer;
  final Function(UserTokenPosition position) onSellPosition;

  const CatalogMarketSection({
    super.key,
    required this.isBuySelected,
    required this.onModeChanged,
    required this.availableOffers,
    required this.userOffers,
    required this.userPositions,
    required this.availableBalance,
    required this.totalTokensInWallet,
    required this.buyOfferSort,
    required this.onBuyOfferSortChanged,
    required this.formatCurrency,
    required this.onBuyOffer,
    required this.onCancelOffer,
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
    final sortedOffers = _sortedBuyOffers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MarketInfoCard(
                label: 'Saldo',
                value: formatCurrency(availableBalance),
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
        Align(
          alignment: Alignment.centerRight,
          child: _SortMenu(
            value: buyOfferSort,
            onChanged: onBuyOfferSortChanged,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Escolha uma oferta para comprar tokens de uma startup.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        if (sortedOffers.isEmpty)
          const _MarketEmptyState(
            icon: Icons.storefront_rounded,
            title: 'Nenhuma oferta aberta',
            description:
                'Quando alguem publicar uma venda, ela aparecera aqui para todos.',
          )
        else
          ...sortedOffers.map(
            (offer) => CatalogMarketOfferCard(
              offer: offer,
              formatCurrency: formatCurrency,
              onBuy: () => onBuyOffer(offer),
            ),
          ),
      ],
    );
  }

  List<AvailableOffer> _sortedBuyOffers() {
    final offers = [...availableOffers];

    offers.sort((a, b) {
      switch (buyOfferSort) {
        case 'Mais recentes':
          return b.createdAtMillis.compareTo(a.createdAtMillis);
        case 'Maior quantidade':
          return b.quantity.compareTo(a.quantity);
        case 'Maior preco':
          return b.unitPrice.compareTo(a.unitPrice);
        case 'Menor preco':
        default:
          return a.unitPrice.compareTo(b.unitPrice);
      }
    });

    return offers;
  }

  Widget _buildSellMarketContent() {
    final reservedTokens = userOffers.fold<int>(
      0,
      (sum, offer) => sum + offer.quantity,
    );
    final totalTokens = totalTokensInWallet + reservedTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MarketInfoCard(
                label: 'Disponiveis',
                value: totalTokensInWallet.toString(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MarketInfoCard(
                label: 'Reservados',
                value: reservedTokens.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MarketInfoCard(
                label: 'Total',
                value: totalTokens.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Suas ofertas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        if (userOffers.isEmpty)
          const _MarketEmptyState(
            icon: Icons.sell_outlined,
            title: 'Nenhuma oferta aberta',
            description:
                'As ofertas de venda que voce publicar aparecerao aqui.',
          )
        else
          ...userOffers.map(
            (offer) => _UserOfferCard(
              offer: offer,
              formatCurrency: formatCurrency,
              onCancel: () => onCancelOffer(offer),
            ),
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
        if (userPositions.isEmpty)
          const _MarketEmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Nenhum token na carteira',
            description:
                'Compre tokens de uma startup para criar ofertas de venda.',
          )
        else
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

class _UserOfferCard extends StatelessWidget {
  final AvailableOffer offer;
  final String Function(double value) formatCurrency;
  final VoidCallback onCancel;

  const _UserOfferCard({
    required this.offer,
    required this.formatCurrency,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final total = offer.quantity * offer.unitPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.sell_rounded,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.startup,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Oferta aberta',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
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
                  label: 'Preco/token',
                  value: formatCurrency(offer.unitPrice),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MiniInfo(
                  label: 'Total',
                  value: formatCurrency(total),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.close_rounded, size: 20),
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
                'Cancelar oferta',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SortMenu({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = [
      'Menor preco',
      'Maior preco',
      'Mais recentes',
      'Maior quantidade',
    ];

    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      color: const Color(0xFF102235),
      itemBuilder: (context) {
        return options.map((option) {
          return PopupMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sort_rounded,
              color: AppColors.primaryLight,
              size: 18,
            ),
            const SizedBox(width: 7),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _MarketEmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
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
