import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../services/catalog_service.dart';
import '../../startup/models/startup_model.dart';
import '../../startup/pages/startup_detail_page.dart';
import '../../profile/pages/profile_page.dart';
import '../widgets/catalog_startup_card.dart';
import '../widgets/catalog_market_offer_card.dart';
import '../widgets/catalog_user_position_card.dart';
import '../widgets/catalog_filter_section.dart';
import '../widgets/catalog_navigation_tabs.dart';
import '../widgets/catalog_guidance_box.dart';
import '../widgets/catalog_market_section.dart';
import '../widgets/catalog_sell_offer_sheet.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../core/utils/app_formatters.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  bool showMarket = false;
  bool isBuySelected = true;
  bool showGuidance = true;
  String buyOfferSort = 'Menor preco';

  final TextEditingController _searchController = TextEditingController();

  String selectedSector = 'Setores';
  String selectedStage = 'Estágios';

  final CatalogService _startupService = CatalogService();

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
      body: AppBackground(
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
                    PageHeader(
                      title: showMarket
                          ? 'Balcão de negociações'
                          : 'Catálogo de startups',
                      subtitle: showMarket
                          ? 'Compre tokens disponíveis ou crie uma oferta de venda com seus tokens.'
                          : 'Conheça startups disponíveis e escolha onde deseja investir.',
                      trailing: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfilePage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    CatalogNavigationTabs(
                      showMarket: showMarket,
                      onChanged: (value) {
                        setState(() {
                          showMarket = value;
                        });
                      },
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
                          child: CatalogGuidanceBox(
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

  Widget _buildMarketContent() {
    return StreamBuilder<List<AvailableOffer>>(
      stream: _startupService.watchOpenOffers(),
      builder: (context, offersSnapshot) {
        return StreamBuilder<List<AvailableOffer>>(
          stream: _startupService.watchCurrentUserOpenOffers(),
          builder: (context, userOffersSnapshot) {
            return StreamBuilder<List<UserTokenPosition>>(
              stream: _startupService.watchCurrentUserPositions(),
              builder: (context, positionsSnapshot) {
                return StreamBuilder<double>(
                  stream: _startupService.watchCurrentUserBalance(),
                  builder: (context, balanceSnapshot) {
                    if (offersSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        userOffersSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        positionsSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        balanceSnapshot.connectionState ==
                            ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: AppLoading(message: 'Carregando balcao...'),
                      );
                    }

                    if (offersSnapshot.hasError ||
                        userOffersSnapshot.hasError ||
                        positionsSnapshot.hasError ||
                        balanceSnapshot.hasError) {
                      return const AppErrorState(
                        message: 'Nao foi possivel carregar o balcao.',
                      );
                    }

                    final offers = offersSnapshot.data ?? [];
                    final userOffers = userOffersSnapshot.data ?? [];
                    final positions = positionsSnapshot.data ?? [];
                    final totalTokensInWallet = positions.fold<int>(
                      0,
                      (sum, position) => sum + position.tokensOwned,
                    );
                    return CatalogMarketSection(
                      isBuySelected: isBuySelected,
                      onModeChanged: (value) {
                        setState(() {
                          isBuySelected = value;
                        });
                      },
                      availableOffers: offers,
                      userOffers: userOffers,
                      userPositions: positions,
                      availableBalance: balanceSnapshot.data ?? 0,
                      totalTokensInWallet: totalTokensInWallet,
                      buyOfferSort: buyOfferSort,
                      onBuyOfferSortChanged: (value) {
                        setState(() {
                          buyOfferSort = value;
                        });
                      },
                      formatCurrency: AppFormatters.currency,
                      onBuyOffer: (offer) =>
                          _showBuyQuantityDialog(context, offer),
                      onCancelOffer: (offer) =>
                          _showCancelOfferDialog(context, offer),
                      onSellPosition: (position) =>
                          _openSellOfferSheet(context, position),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStartupCatalogContent() {
    return StreamBuilder<List<StartupModel>>(
      stream: _startupService.watchStartups(),
      builder: (context, snapshot) {
        final startups = snapshot.data ?? [];

        final dynamicSectors = startups
            .expand((s) => s.categories)
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.compareTo(b));

        final sectorOptions = [
          'Setores',
          ...dynamicSectors,
        ];

        final dynamicStages = startups
            .map((s) => s.stage.trim())
            .where((st) => st.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.compareTo(b));

        final stageOptions = [
          'Estágios',
          ...dynamicStages,
        ];

        if (!sectorOptions.contains(selectedSector)) {
          selectedSector = 'Setores';
        }

        if (!stageOptions.contains(selectedStage)) {
          selectedStage = 'Estágios';
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

          final matchesSector = selectedSector == 'Setores' ||
              startup.categories.any((c) => c.trim().toLowerCase() == selectedSector.trim().toLowerCase()) ||
              startup.sector.trim().toLowerCase() == selectedSector.trim().toLowerCase();

          final matchesStage =
              selectedStage == 'Estágios' ||
                  startup.stage.toLowerCase() == selectedStage.toLowerCase();

          return matchesSearch && matchesSector && matchesStage;
        }).toList();

        return Column(
          key: const ValueKey('startup-content'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CatalogFilterSection(
              searchController: _searchController,
              selectedSector: selectedSector,
              selectedStage: selectedStage,
              sectors: sectorOptions,
              stages: stageOptions,
              onSectorChanged: (value) {
                setState(() {
                  selectedSector = value;
                });
              },
              onStageChanged: (value) {
                setState(() {
                  selectedStage = value;
                });
              },
              onSearchChanged: (_) {
                setState(() {});
              },
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
                padding: EdgeInsets.only(top: 30),
                child: AppLoading(message: 'Carregando startups...'),
              )
            else if (snapshot.hasError)
              const AppErrorState(
                message: 'Não foi possível carregar as startups do Firestore.',
              )
            else if (startups.isEmpty)
              const AppErrorState(
                title: 'Nenhuma startup',
                message: 'Nenhuma startup cadastrada no Firestore ainda.',
                icon: Icons.rocket_launch_rounded,
              )
            else if (filteredStartups.isEmpty)
              const AppErrorState(
                title: 'Sem resultados',
                message: 'Nenhuma startup encontrada com esses filtros.',
                icon: Icons.search_off_rounded,
              )
            else
              Column(
                    children: filteredStartups
                        .map(
                          (startup) => CatalogStartupCard(
                        startup: startup,
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


  void _showBuyOfferDialog(BuildContext context, AvailableOffer offer) {
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
          'Você está comprando ${offer.quantity} tokens da ${offer.startup} por ${AppFormatters.currency(total)}.',
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
            onPressed: () async {
              Navigator.pop(context);
              await _buyMarketOffer(offer);
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

  void _showBuyQuantityDialog(BuildContext context, AvailableOffer offer) {
    final quantityController =
        TextEditingController(text: offer.quantity.toString());

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          final quantity = int.tryParse(quantityController.text) ?? 0;
          final total = quantity * offer.unitPrice;
          final canBuy = quantity > 0 && quantity <= offer.quantity;

          return AlertDialog(
            backgroundColor: const Color(0xFF102235),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Confirmar compra',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escolha quantos tokens da ${offer.startup} deseja comprar.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setDialogState(() {}),
                  decoration: _inputDecoration('Maximo: ${offer.quantity}'),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total: ${AppFormatters.currency(total)}',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  quantityController.dispose();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: canBuy
                    ? () async {
                        quantityController.dispose();
                        Navigator.pop(context);
                        await _buyMarketOfferQuantity(offer, quantity);
                      }
                    : null,
                child: const Text(
                  'Comprar',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _buyMarketOffer(AvailableOffer offer) async {
    try {
      await _startupService.buyMarketOffer(offerId: offer.id);

      if (!mounted) return;

      _showBuyResultDialog(offer);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyFunctionError(error))),
      );
    }
  }

  Future<void> _buyMarketOfferQuantity(
    AvailableOffer offer,
    int quantity,
  ) async {
    try {
      await _startupService.buyMarketOfferQuantity(
        offerId: offer.id,
        quantity: quantity,
      );

      if (!mounted) return;

      _showBuyQuantityResultDialog(offer, quantity);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyFunctionError(error))),
      );
    }
  }

  void _showCancelOfferDialog(BuildContext context, AvailableOffer offer) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF102235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Cancelar oferta',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Deseja cancelar sua oferta de ${offer.quantity} tokens da ${offer.startup}? Os tokens restantes voltarao para a carteira.',
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Voltar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelSellOffer(offer);
            },
            child: const Text(
              'Cancelar oferta',
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

  Future<void> _cancelSellOffer(AvailableOffer offer) async {
    try {
      await _startupService.cancelSellOffer(offerId: offer.id);

      if (!mounted) return;

      _showCancelResultDialog(offer);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyFunctionError(error))),
      );
    }
  }

  void _showCancelResultDialog(AvailableOffer offer) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF102235),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Venda cancelada',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '${offer.quantity} tokens da ${offer.startup} voltaram para sua carteira.',
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

  String _friendlyFunctionError(Object error) {
    if (error is FirebaseFunctionsException) {
      final message = error.message ?? '';

      if (error.code == 'not-found' && message == 'NOT_FOUND') {
        return 'Funcao de cancelamento ainda nao foi publicada. Faca deploy das functions.';
      }

      if (message.contains('propria oferta')) {
        return 'Voce nao pode comprar a propria oferta.';
      }

      if (message == 'saldo_insuficiente') {
        return 'Saldo insuficiente para comprar esta oferta.';
      }

      if (message.contains('Quantidade indisponivel')) {
        return 'Essa quantidade nao esta mais disponivel na oferta.';
      }

      if (message.contains('quantidade deve ser')) {
        return 'Informe uma quantidade valida de tokens.';
      }

      if (message.contains('Oferta indisponivel')) {
        return 'Essa oferta nao esta mais disponivel.';
      }

      if (message.contains('cancelar suas proprias ofertas')) {
        return 'Voce so pode cancelar suas proprias ofertas.';
      }

      if (message.contains('indisponivel para cancelamento')) {
        return 'Essa oferta nao esta mais disponivel para cancelamento.';
      }

      if (message.isNotEmpty) {
        return message;
      }
    }

    return 'Nao foi possivel concluir a operacao. Tente novamente.';
  }

  void _showBuyResultDialog(AvailableOffer offer) {
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
          'A compra dos tokens da ${offer.startup} foi concluída com sucesso.',
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

  void _showBuyQuantityResultDialog(AvailableOffer offer, int quantity) {
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
          'A compra de $quantity tokens da ${offer.startup} foi concluida com sucesso.',
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

  void _openSellOfferSheet(BuildContext context, UserTokenPosition position) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return CatalogSellOfferSheet(
          position: position,
          formatCurrency: AppFormatters.currency,
          inputDecoration: _inputDecoration,
          onPublish: ({
            required UserTokenPosition position,
            required int quantity,
            required double price,
            required double total,
          }) async {
            try {
              await _startupService.createSellOffer(
                startupId: position.startupId,
                quantity: quantity,
                unitPrice: price,
              );

              if (!mounted) return;

              _showSellResultDialog(
                position: position,
                quantity: quantity,
                price: price,
                total: total,
              );
            } catch (error) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_friendlyFunctionError(error))),
              );
            }
          },
        );
      },
    );
  }

  void _showSellResultDialog({
    required UserTokenPosition position,
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
          'Sua oferta de venda de $quantity tokens da ${position.startup} foi registrada por ${AppFormatters.currency(price)} cada, totalizando ${AppFormatters.currency(total)}.',
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

