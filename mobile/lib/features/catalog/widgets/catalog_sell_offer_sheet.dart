// Widget responsável por exibir o formulário de criação de oferta de venda.
//
// Isola o BottomSheet do balcão de negociações e controla internamente
// os TextEditingControllers usados no formulário.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import 'catalog_market_offer_card.dart'; // Para MiniInfo
import 'catalog_user_position_card.dart'; // Para UserTokenPosition e SummaryRow

class CatalogSellOfferSheet extends StatefulWidget {
  final UserTokenPosition position;
  final String Function(double value) formatCurrency;
  final InputDecoration Function(String hint) inputDecoration;
  final Function({
    required UserTokenPosition position,
    required int quantity,
    required double price,
    required double total,
  }) onPublish;

  const CatalogSellOfferSheet({
    super.key,
    required this.position,
    required this.formatCurrency,
    required this.inputDecoration,
    required this.onPublish,
  });

  @override
  State<CatalogSellOfferSheet> createState() => _CatalogSellOfferSheetState();
}

class _CatalogSellOfferSheetState extends State<CatalogSellOfferSheet> {
  late final TextEditingController sellQuantityController;
  late final TextEditingController sellPriceController;

  @override
  void initState() {
    super.initState();
    sellQuantityController = TextEditingController();
    sellPriceController = TextEditingController(
      text: widget.position.currentPrice.toStringAsFixed(2).replaceAll('.', ','),
    );
  }

  @override
  void dispose() {
    sellQuantityController.dispose();
    sellPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int sellQuantity = int.tryParse(sellQuantityController.text) ?? 0;

    final double sellPrice = double.tryParse(
      sellPriceController.text.replaceAll(',', '.'),
    ) ?? 0;

    final double total = sellQuantity * sellPrice;

    final bool hasValidQuantity = sellQuantity > 0;
    final bool hasValidPrice = sellPrice > 0;
    final bool hasEnoughTokens = sellQuantity <= widget.position.tokensOwned;

    final bool canPublish = hasValidQuantity && hasValidPrice && hasEnoughTokens;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF071A2B),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.42),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.45,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(
                          alpha: 0.30,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.sell_rounded,
                      color: AppColors.primaryLight,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Criar oferta de venda',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Você está criando uma oferta de venda para os tokens da ${widget.position.startup}.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
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
                      widget.position.startup,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.position.sector,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: MiniInfo(
                            label: 'Você possui',
                            value: '${widget.position.tokensOwned} tokens',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MiniInfo(
                            label: 'Valor atual',
                            value: widget.formatCurrency(
                              widget.position.currentPrice,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Quantidade para vender',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sellQuantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: widget.inputDecoration(
                  'Máximo: ${widget.position.tokensOwned} tokens',
                ),
                style: const TextStyle(color: Colors.white),
              ),
              if (sellQuantity > widget.position.tokensOwned) ...[
                const SizedBox(height: 8),
                Text(
                  'Você só possui ${widget.position.tokensOwned} tokens disponíveis para venda.',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'Preço desejado por token',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sellPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                onChanged: (_) => setState(() {}),
                decoration: widget.inputDecoration(
                  'Valor atual: ${widget.formatCurrency(widget.position.currentPrice)}',
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumo da oferta',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const SummaryRow(
                      label: 'Operação',
                      value: 'Venda',
                      highlight: true,
                    ),
                    SummaryRow(
                      label: 'Startup',
                      value: widget.position.startup,
                    ),
                    SummaryRow(
                      label: 'Tokens disponíveis',
                      value: '${widget.position.tokensOwned}',
                    ),
                    SummaryRow(
                      label: 'Quantidade escolhida',
                      value: sellQuantity.toString(),
                    ),
                    SummaryRow(
                      label: 'Valor atual do token',
                      value: widget.formatCurrency(widget.position.currentPrice),
                    ),
                    SummaryRow(
                      label: 'Preço de venda',
                      value: widget.formatCurrency(sellPrice),
                    ),
                    SummaryRow(
                      label: 'Valor total',
                      value: widget.formatCurrency(total),
                      highlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: canPublish
                      ? () {
                    Navigator.pop(context);
                    widget.onPublish(
                      position: widget.position,
                      quantity: sellQuantity,
                      price: sellPrice,
                      total: total,
                    );
                  }
                      : null,
                  icon: const Icon(Icons.sell_rounded),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white.withValues(
                      alpha: 0.08,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  label: const Text(
                    'Publicar oferta de venda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
