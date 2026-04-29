import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/mock_startups.dart';
import '../models/startup_model.dart';
import '../widgets/startup_card.dart';
import 'startup_details_page.dart';
import '../../profile/pages/profile_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  bool showMarket = false;
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            showMarket
                                ? 'Balcão de negociações'
                                : 'Catálogo de startups',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfilePage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      showMarket
                          ? 'Negocie tokens simulados de startups em compra ou venda.'
                          : 'Conheça startups disponíveis e escolha onde deseja investir.',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 22),

                    _MainNavigationSelector(
                      showMarket: showMarket,
                      onSelectStartups: () {
                        setState(() {
                          showMarket = false;
                        });
                      },
                      onSelectMarket: () {
                        setState(() {
                          showMarket = true;
                        });
                      },
                    ),

                    const SizedBox(height: 22),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: showMarket
                          ? _buildMarketContent()
                          : _buildStartupCatalogContent(),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartupCatalogContent() {
    return Column(
      key: const ValueKey('startup-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GuidanceBox(
          icon: Icons.rocket_launch_rounded,
          title: 'Investir em uma startup',
          description:
          'Toque em uma startup para ver detalhes, documentos e a opção de investimento.',
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar startup',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.03),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Expanded(
                    child: _FilterChipBox(text: 'Todos os setores'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _FilterChipBox(text: 'Todos os estágios'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Startups disponíveis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 14),

        ...mockStartups.map(
              (startup) => StartupCard(
            name: startup.name,
            sector: startup.sector,
            stage: startup.stage,
            description: startup.description,
            capital: startup.capital,
            tokens: startup.tokens,
            onTap: () => _openDetails(context, startup),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketContent() {
    return Column(
      key: const ValueKey('market-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GuidanceBox(
          icon: Icons.swap_horiz_rounded,
          title: 'Balcão de negociações',
          description:
          'Aqui você registra ofertas simuladas para comprar ou vender tokens.',
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _ModeButton(
                icon: Icons.add_shopping_cart_rounded,
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
                icon: Icons.sell_rounded,
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

        const SizedBox(height: 14),

        _ActiveModeNotice(isBuySelected: isBuySelected),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBuySelected ? 'Nova compra' : 'Nova venda',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                isBuySelected
                    ? 'Informe a startup, quantidade e preço máximo.'
                    : 'Informe a startup, quantidade e preço desejado.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Startup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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

              const Row(
                children: [
                  Expanded(
                    child: _MarketInfoCard(
                      label: 'Preço atual',
                      value: 'R\$ 12,50',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MarketInfoCard(
                      label: 'Saldo',
                      value: 'R\$ 5.000,00',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                isBuySelected
                    ? 'Quantidade para comprar'
                    : 'Quantidade para vender',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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

              Text(
                isBuySelected
                    ? 'Preço máximo por token'
                    : 'Preço desejado por token',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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

              const SizedBox(height: 20),

              _OrderSummary(
                isBuySelected: isBuySelected,
                selectedStartup: selectedStartup,
                quantity: quantity,
                priceText: priceController.text,
                total: _formatCurrency(total),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: quantity <= 0 || unitPrice <= 0
                      ? null
                      : () => _showResultDialog(context),
                  icon: Icon(
                    isBuySelected
                        ? Icons.add_shopping_cart_rounded
                        : Icons.sell_rounded,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    Colors.white.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  label: Text(
                    isBuySelected
                        ? 'Confirmar compra'
                        : 'Confirmar venda',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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
      ],
    );
  }

  void _openDetails(BuildContext context, StartupModel startup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StartupDetailsPage(
          name: startup.name,
          sector: startup.sector,
          stage: startup.stage,
          description: startup.description,
          capital: startup.capital,
          tokens: startup.tokens,
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

class _MainNavigationSelector extends StatelessWidget {
  final bool showMarket;
  final VoidCallback onSelectStartups;
  final VoidCallback onSelectMarket;

  const _MainNavigationSelector({
    required this.showMarket,
    required this.onSelectStartups,
    required this.onSelectMarket,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavigationOption(
              icon: Icons.rocket_launch_rounded,
              text: 'Startups',
              selected: !showMarket,
              onTap: onSelectStartups,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _NavigationOption(
              icon: Icons.swap_horiz_rounded,
              text: 'Balcão',
              selected: showMarket,
              onTap: onSelectMarket,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationOption({
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
        borderRadius: BorderRadius.circular(21),
        boxShadow: selected
            ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(21),
          child: Ink(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.22)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.75)
                    : Colors.transparent,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.32)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryLight.withValues(alpha: 0.58)
                                : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: selected
                              ? AppColors.primaryLight
                              : AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          text,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 14.5,
                            fontWeight:
                            selected ? FontWeight.w900 : FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 7,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(999),
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

class _GuidanceBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GuidanceBox({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.2,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipBox extends StatelessWidget {
  final String text;

  const _FilterChipBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.75)
                : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primaryLight : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: selected ? AppColors.primaryLight : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryLight,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActiveModeNotice extends StatelessWidget {
  final bool isBuySelected;

  const _ActiveModeNotice({
    required this.isBuySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        isBuySelected
            ? 'Modo compra ativo: você está criando uma oferta para adquirir tokens.'
            : 'Modo venda ativo: você está criando uma oferta para vender tokens.',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13.2,
          height: 1.35,
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

class _MarketInfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _MarketInfoCard({
    required this.label,
    required this.value,
  });

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
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
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

class _OrderSummary extends StatelessWidget {
  final bool isBuySelected;
  final String selectedStartup;
  final int quantity;
  final String priceText;
  final String total;

  const _OrderSummary({
    required this.isBuySelected,
    required this.selectedStartup,
    required this.quantity,
    required this.priceText,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Operação',
            value: isBuySelected ? 'Compra' : 'Venda',
            highlight: true,
          ),
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
            value: 'R\$ $priceText',
          ),
          _SummaryRow(
            label: 'Valor total',
            value: total,
            highlight: true,
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
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppColors.primaryLight : Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
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
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              type,
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w800,
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
          Icon(
            isBuy ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: AppColors.primaryLight,
            size: 18,
          ),
          const SizedBox(width: 6),
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