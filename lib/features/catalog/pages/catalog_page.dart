import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/catalog_service.dart';
import '../../startup/models/startup_model.dart';
import '../../startup/pages/startup_detail_page.dart';
import '../../profile/pages/profile_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  bool showMarket = false;
  bool isBuySelected = true;
  bool showGuidance = true;

  final TextEditingController _searchController = TextEditingController();

  String selectedSector = 'Todos os setores';
  String selectedStage = 'Todos os estágios';

  final CatalogService _startupService = CatalogService();

  final List<_AvailableOffer> availableOffers = const [
    _AvailableOffer(
      startup: 'VisionAI Health',
      sector: 'Saúde e IA',
      stage: 'Em expansão',
      quantity: 42,
      unitPrice: 12.50,
      variation: '+6,2%',
    ),
    _AvailableOffer(
      startup: 'GreenVolt Hub',
      sector: 'Energia limpa',
      stage: 'Em operação',
      quantity: 80,
      unitPrice: 9.80,
      variation: '+3,4%',
    ),
    _AvailableOffer(
      startup: 'AgroLink Data',
      sector: 'Agrotech',
      stage: 'Nova',
      quantity: 35,
      unitPrice: 7.10,
      variation: '-1,2%',
    ),
  ];

  final List<_UserTokenPosition> userPositions = const [
    _UserTokenPosition(
      startup: 'VisionAI Health',
      sector: 'Saúde e IA',
      tokensOwned: 20,
      currentPrice: 12.50,
      variation: '+6,2%',
    ),
    _UserTokenPosition(
      startup: 'GreenVolt Hub',
      sector: 'Energia limpa',
      tokensOwned: 14,
      currentPrice: 9.80,
      variation: '+3,4%',
    ),
    _UserTokenPosition(
      startup: 'AgroLink Data',
      sector: 'Agrotech',
      tokensOwned: 8,
      currentPrice: 7.10,
      variation: '-1,2%',
    ),
  ];

  int get totalTokensInWallet {
    return userPositions.fold(0, (sum, position) => sum + position.tokensOwned);
  }

  double get estimatedWalletValue {
    return userPositions.fold(
      0,
          (sum, position) => sum + (position.tokensOwned * position.currentPrice),
    );
  }

  void _selectStartups() {
    setState(() {
      showMarket = false;
    });
  }

  void _selectMarket() {
    setState(() {
      showMarket = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _guidanceTitle {
    return showMarket ? 'Balcão de negociações' : 'Investir em uma startup';
  }

  String get _guidanceDescription {
    return showMarket
        ? 'Compre tokens disponíveis ou crie uma oferta de venda usando os tokens que você já possui.'
        : 'Toque em uma startup para ver detalhes, perguntas públicas e opção de investimento.';
  }

  IconData get _guidanceIcon {
    return showMarket ? Icons.swap_horiz_rounded : Icons.rocket_launch_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF04111D), Color(0xFF071A2B), Color(0xFF0A2235)],
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
                          ? 'Compre tokens disponíveis ou crie uma oferta de venda com seus tokens.'
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
                      onSelectStartups: _selectStartups,
                      onSelectMarket: _selectMarket,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: showGuidance
                            ? Padding(
                          key: ValueKey('guidance-$showMarket'),
                          padding: const EdgeInsets.only(top: 18),
                          child: _GuidanceBox(
                            icon: _guidanceIcon,
                            title: _guidanceTitle,
                            description: _guidanceDescription,
                            onClose: () {
                              setState(() {
                                showGuidance = false;
                              });
                            },
                          ),
                        )
                            : const SizedBox.shrink(
                          key: ValueKey('empty-guidance'),
                        ),
                      ),
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
    return StreamBuilder<List<StartupModel>>(
      stream: _startupService.watchStartups(),
      builder: (context, snapshot) {
        final startups = snapshot.data ?? [];

        final sectorOptions = [
          'Todos os setores',
          ...{
            for (final startup in startups)
              for (final category in startup.categories)
                if (category.trim().isNotEmpty) category.trim(),
          },
        ];

        final stageOptions = [
          'Todos os estágios',
          ...{
            for (final startup in startups)
              if (startup.stage.trim().isNotEmpty) startup.stage.trim(),
          },
        ];

        if (!sectorOptions.contains(selectedSector)) {
          selectedSector = 'Todos os setores';
        }

        if (!stageOptions.contains(selectedStage)) {
          selectedStage = 'Todos os estágios';
        }

        final searchText = _searchController.text.trim().toLowerCase();

        final filteredStartups = startups.where((startup) {
          final name = startup.name.toLowerCase();
          final sector = startup.sector.toLowerCase();
          final stage = startup.stage.toLowerCase();
          final description = startup.description.toLowerCase();

          final categories = startup.categories
              .map((category) => category.toLowerCase())
              .toList();

          final matchesSearch =
              searchText.isEmpty ||
                  name.contains(searchText) ||
                  sector.contains(searchText) ||
                  stage.contains(searchText) ||
                  description.contains(searchText) ||
                  categories.any((category) => category.contains(searchText));

          final matchesSector =
              selectedSector == 'Todos os setores' ||
                  categories.contains(selectedSector.toLowerCase());

          final matchesStage =
              selectedStage == 'Todos os estágios' ||
                  startup.stage.toLowerCase() == selectedStage.toLowerCase();

          return matchesSearch && matchesSector && matchesStage;
        }).toList();

        return Column(
          key: const ValueKey('startup-content'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
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
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterChipBox(
                          text: selectedSector,
                          options: sectorOptions,
                          onSelected: (value) {
                            setState(() {
                              selectedSector = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterChipBox(
                          text: selectedStage,
                          options: stageOptions,
                          onSelected: (value) {
                            setState(() {
                              selectedStage = value;
                            });
                          },
                        ),
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
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryLight,
                  ),
                ),
              )
            else if (snapshot.hasError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Não foi possível carregar as startups do Firestore.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              )
            else if (startups.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'Nenhuma startup cadastrada no Firestore ainda.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                )
              else if (filteredStartups.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'Nenhuma startup encontrada com esses filtros.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  )
                else
                  Column(
                    children: filteredStartups
                        .map(
                          (startup) => _StartupCatalogCard(
                        name: startup.name,
                        categories: startup.categories,
                        stage: startup.stage,
                        description: startup.description,
                        capital: startup.capital,
                        tokens: startup.tokens,
                        onTap: () => _openDetails(context, startup),
                      ),
                    )
                        .toList(),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildMarketContent() {
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
                label: 'Saldo fictício',
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
          'Escolha uma oferta para comprar tokens simulados de uma startup.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        ...availableOffers.map(
              (offer) => _AvailableOfferCard(
            offer: offer,
            formatCurrency: _formatCurrency,
            onBuy: () => _showBuyOfferDialog(context, offer),
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
                value: _formatCurrency(estimatedWalletValue),
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
              (position) => _UserTokenCard(
            position: position,
            formatCurrency: _formatCurrency,
            onSell: () => _openSellOfferSheet(context, position),
          ),
        ),
      ],
    );
  }

  void _openDetails(BuildContext context, StartupModel startup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StartupDetailPage(
          startup: startup,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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

  void _showBuyOfferDialog(BuildContext context, _AvailableOffer offer) {
    final total = offer.quantity * offer.unitPrice;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF102235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Confirmar compra',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Você está comprando ${offer.quantity} tokens da ${offer.startup} por ${_formatCurrency(total)}.',
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showBuyResultDialog(offer);
            },
            child: const Text(
              'Comprar',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyResultDialog(_AvailableOffer offer) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF102235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Compra confirmada',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'A compra simulada dos tokens da ${offer.startup} foi concluída com sucesso.',
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fechar',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _openSellOfferSheet(BuildContext context, _UserTokenPosition position) {
    final TextEditingController sellQuantityController =
    TextEditingController();

    final TextEditingController sellPriceController = TextEditingController(
      text: position.currentPrice.toStringAsFixed(2).replaceAll('.', ','),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final int sellQuantity =
                int.tryParse(sellQuantityController.text) ?? 0;

            final double sellPrice =
                double.tryParse(
                  sellPriceController.text.replaceAll(',', '.'),
                ) ??
                    0;

            final double total = sellQuantity * sellPrice;

            final bool hasValidQuantity = sellQuantity > 0;
            final bool hasValidPrice = sellPrice > 0;
            final bool hasEnoughTokens = sellQuantity <= position.tokensOwned;

            final bool canPublish =
                hasValidQuantity && hasValidPrice && hasEnoughTokens;

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
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Você está criando uma oferta de venda para os tokens da ${position.startup}.',
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
                              position.startup,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              position.sector,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _MiniInfo(
                                    label: 'Você possui',
                                    value: '${position.tokensOwned} tokens',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _MiniInfo(
                                    label: 'Valor atual',
                                    value: _formatCurrency(
                                      position.currentPrice,
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
                        onChanged: (_) => setModalState(() {}),
                        decoration: _inputDecoration(
                          'Máximo: ${position.tokensOwned} tokens',
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (sellQuantity > position.tokensOwned) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Você só possui ${position.tokensOwned} tokens disponíveis para venda.',
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
                        onChanged: (_) => setModalState(() {}),
                        decoration: _inputDecoration(
                          'Valor atual: ${_formatCurrency(position.currentPrice)}',
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
                            const _SummaryRow(
                              label: 'Operação',
                              value: 'Venda',
                              highlight: true,
                            ),
                            _SummaryRow(
                              label: 'Startup',
                              value: position.startup,
                            ),
                            _SummaryRow(
                              label: 'Tokens disponíveis',
                              value: '${position.tokensOwned}',
                            ),
                            _SummaryRow(
                              label: 'Quantidade escolhida',
                              value: sellQuantity.toString(),
                            ),
                            _SummaryRow(
                              label: 'Valor atual do token',
                              value: _formatCurrency(position.currentPrice),
                            ),
                            _SummaryRow(
                              label: 'Preço de venda',
                              value: _formatCurrency(sellPrice),
                            ),
                            _SummaryRow(
                              label: 'Valor total',
                              value: _formatCurrency(total),
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
                            Navigator.pop(sheetContext);
                            _showSellResultDialog(
                              position: position,
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
          },
        );
      },
    ).whenComplete(() {
      sellQuantityController.dispose();
      sellPriceController.dispose();
    });
  }

  void _showSellResultDialog({
    required _UserTokenPosition position,
    required int quantity,
    required double price,
    required double total,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF102235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Oferta publicada',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Sua oferta de venda de $quantity tokens da ${position.startup} foi registrada por ${_formatCurrency(price)} cada, totalizando ${_formatCurrency(total)}.',
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fechar',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartupCatalogCard extends StatelessWidget {
  final String name;
  final List<String> categories;
  final String stage;
  final String description;
  final String capital;
  final String tokens;
  final VoidCallback onTap;

  const _StartupCatalogCard({
    required this.name,
    required this.categories,
    required this.stage,
    required this.description,
    required this.capital,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCategories = categories.take(2).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOPO: tags simples à esquerda e estágio no extremo direito
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: visibleCategories.isEmpty
                    ? const SizedBox.shrink()
                    : Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: visibleCategories.map((category) {
                    return _CategoryTag(text: category);
                  }).toList(),
                ),
              ),
              const SizedBox(width: 16),
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  stage,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _StartupLogo(name: name),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _StartupMetricBox(label: 'Capital', value: capital),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StartupMetricBox(label: 'Tokens', value: tokens),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                'Ver mais',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String text;

  const _CategoryTag({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.sell_rounded, color: AppColors.primaryLight, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.primaryLight,
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _StartupLogo extends StatelessWidget {
  final String name;

  const _StartupLogo({required this.name});

  String get initials {
    final words = name
        .trim()
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .toList();

    if (words.isEmpty) return 'ST';

    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.primaryLight.withValues(alpha: 0.60),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _StartupMetricBox extends StatelessWidget {
  final String label;
  final String value;

  const _StartupMetricBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableOffer {
  final String startup;
  final String sector;
  final String stage;
  final int quantity;
  final double unitPrice;
  final String variation;

  const _AvailableOffer({
    required this.startup,
    required this.sector,
    required this.stage,
    required this.quantity,
    required this.unitPrice,
    required this.variation,
  });
}

class _UserTokenPosition {
  final String startup;
  final String sector;
  final int tokensOwned;
  final double currentPrice;
  final String variation;

  const _UserTokenPosition({
    required this.startup,
    required this.sector,
    required this.tokensOwned,
    required this.currentPrice,
    required this.variation,
  });
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
        border: Border.all(color: AppColors.border),
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
                            fontWeight: selected
                                ? FontWeight.w900
                                : FontWeight.w700,
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
  final VoidCallback onClose;

  const _GuidanceBox({
    required this.icon,
    required this.title,
    required this.description,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
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
            child: Icon(icon, color: Colors.white, size: 20),
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
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClose,
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipBox extends StatelessWidget {
  final String text;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _FilterChipBox({
    required this.text,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color(0xFF102235),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      onSelected: onSelected,
      itemBuilder: (context) {
        return options.map((option) {
          final bool isSelected = option == text;

          return PopupMenuItem<String>(
            value: option,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? AppColors.primaryLight : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.primaryLight,
                    size: 18,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: text.startsWith('Todos')
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.65),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: text.startsWith('Todos')
                      ? Colors.white
                      : AppColors.primaryLight,
                  fontSize: 14,
                  fontWeight: text.startsWith('Todos')
                      ? FontWeight.w500
                      : FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
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
                    ? AppColors.primary.withValues(alpha: 0.75)
                    : AppColors.border,
                width: selected ? 1.4 : 1,
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

class _AvailableOfferCard extends StatelessWidget {
  final _AvailableOffer offer;
  final String Function(double value) formatCurrency;
  final VoidCallback onBuy;

  const _AvailableOfferCard({
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
              _StartupLogo(name: offer.startup),
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
                child: _MiniInfo(
                  label: 'Quantidade',
                  value: '${offer.quantity} tokens',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniInfo(
                  label: 'Preço/token',
                  value: formatCurrency(offer.unitPrice),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniInfo(label: 'Total', value: formatCurrency(total)),
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

class _UserTokenCard extends StatelessWidget {
  final _UserTokenPosition position;
  final String Function(double value) formatCurrency;
  final VoidCallback onSell;

  const _UserTokenCard({
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
              _StartupLogo(name: position.startup),
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
                child: _MiniInfo(
                  label: 'Você possui',
                  value: '${position.tokensOwned} tokens',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniInfo(
                  label: 'Preço atual',
                  value: formatCurrency(position.currentPrice),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniInfo(
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

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;

  const _MiniInfo({required this.label, required this.value});

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
