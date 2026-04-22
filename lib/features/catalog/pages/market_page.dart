import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  bool isBuySelected = true;
  String selectedStartup = 'VisionAI Health';
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController =
  TextEditingController(text: '12,50');

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  int get quantity => int.tryParse(quantityController.text) ?? 0;

  double get unitPrice =>
      double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0;

  double get total => quantity * unitPrice;

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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Balcão de negociação',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Compre e venda tokens em uma interface de ofertas simuladas.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _ModeButton(
                            text: 'Comprar',
                            selected: isBuySelected,
                            onTap: () {
                              setState(() {
                                isBuySelected = true;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModeButton(
                            text: 'Vender',
                            selected: !isBuySelected,
                            onTap: () {
                              setState(() {
                                isBuySelected = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selecionar startup',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),

                          _StartupSelector(
                            selectedStartup: selectedStartup,
                            onChanged: (value) {
                              setState(() {
                                selectedStartup = value;
                              });
                            },
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: const [
                              Expanded(
                                child: _InfoCard(
                                  label: 'Preço atual',
                                  value: 'R\$ 12,50',
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _InfoCard(
                                  label: 'Saldo disponível',
                                  value: 'R\$ 5.000,00',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Quantidade',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),

                          TextField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: _inputDecoration('Ex: 10'),
                            style: const TextStyle(color: Colors.white),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Preço por token',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),

                          TextField(
                            controller: priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: _inputDecoration('Ex: 12,50'),
                            style: const TextStyle(color: Colors.white),
                          ),

                          const SizedBox(height: 22),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isBuySelected
                                      ? 'Resumo da compra'
                                      : 'Resumo da venda',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _SummaryRow(
                                  label: 'Startup',
                                  value: selectedStartup,
                                ),
                                _SummaryRow(
                                  label: 'Quantidade',
                                  value: quantity.toString(),
                                ),
                                _SummaryRow(
                                  label: 'Preço unitário',
                                  value: 'R\$ ${priceController.text}',
                                ),
                                _SummaryRow(
                                  label: 'Valor total',
                                  value: _formatCurrency(total),
                                  highlight: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: quantity <= 0 || unitPrice <= 0
                                  ? null
                                  : () => _showResultDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                Colors.white.withValues(alpha: 0.08),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                isBuySelected
                                    ? 'Confirmar compra'
                                    : 'Confirmar venda',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Ofertas simuladas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const _OfferCard(
                      type: 'Compra',
                      startup: 'VisionAI Health',
                      price: 'R\$ 12,40',
                      quantity: '150 tokens',
                    ),
                    const _OfferCard(
                      type: 'Venda',
                      startup: 'GreenVolt Hub',
                      price: 'R\$ 9,80',
                      quantity: '200 tokens',
                    ),
                    const _OfferCard(
                      type: 'Compra',
                      startup: 'AgroLink Data',
                      price: 'R\$ 7,10',
                      quantity: '90 tokens',
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _showResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF102235),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          isBuySelected ? 'Compra confirmada' : 'Venda confirmada',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isBuySelected
              ? 'Sua oferta de compra foi registrada com sucesso.'
              : 'Sua oferta de venda foi registrada com sucesso.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fechar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        height: 52,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? AppColors.primaryLight : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _StartupSelector extends StatelessWidget {
  final String selectedStartup;
  final ValueChanged<String> onChanged;

  const _StartupSelector({
    required this.selectedStartup,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final startups = [
      'VisionAI Health',
      'GreenVolt Hub',
      'AgroLink Data',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStartup,
          dropdownColor: const Color(0xFF102235),
          iconEnabledColor: AppColors.textSecondary,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          isExpanded: true,
          items: startups
              .map(
                (startup) => DropdownMenuItem<String>(
              value: startup,
              child: Text(startup),
            ),
          )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({
    required this.label,
    required this.value,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppColors.primaryLight : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String type;
  final String startup;
  final String price;
  final String quantity;

  const _OfferCard({
    required this.type,
    required this.startup,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final isBuy = type == 'Compra';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: (isBuy ? AppColors.primary : Colors.redAccent)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isBuy ? AppColors.primaryLight : Colors.redAccent,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startup,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quantity,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}