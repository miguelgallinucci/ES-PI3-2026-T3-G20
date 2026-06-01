// Alycia Santos Bond - RA 25016465
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/page_header.dart';
import '../services/wallet_service.dart';
import '../widgets/wallet_deposit_sheet.dart';
import '../widgets/wallet_history_item.dart';
import '../widgets/wallet_summary_section.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final WalletService _walletService = WalletService();

  // Abre o BottomSheet para adicionar saldo fictício.
  // O valor selecionado não é escrito no Firestore pelo Flutter;
  // ele é enviado via Cloud Function 'addSimulatedBalance' para validação e
  // escrita atômica, garantindo integridade e centralização da regra de negócio.
  Future<void> _showAddBalanceModal() async {
    final selectedAmount = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: const Color(0xFF071A2B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const WalletDepositSheet(),
    );

    if (selectedAmount == null) return;

    try {
      await _walletService.addSimulatedBalance(selectedAmount);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saldo de ${AppFormatters.currency(selectedAmount)} adicionado.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar saldo: $error')),
      );
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(
            value
                .replaceAll('R\$', '')
                .replaceAll(' ', '')
                .replaceAll('.', '')
                .replaceAll(',', '.'),
          ) ??
          0;
    }
    return 0;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  int _toMillis(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    return 0;
  }

  // desenvolvido por Miguel Gallinucci - acompanha o historico real do preco do token.
  Stream<List<_WalletTokenPricePoint>> _watchTokenPriceHistory(
    String startupId,
  ) {
    if (startupId.trim().isEmpty) {
      return Stream.value(const []);
    }

    return FirebaseFirestore.instance
        .collection('startups')
        .doc(startupId)
        .collection('priceHistory')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => _WalletTokenPricePoint.fromMap(doc.data()))
          .where((point) => point.price > 0)
          .toList();
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _watchStartup(
    String startupId,
  ) {
    return FirebaseFirestore.instance
        .collection('startups')
        .doc(startupId)
        .snapshots();
  }

  List<_WalletTokenPricePoint> _last24HourPriceHistory(
    List<_WalletTokenPricePoint> history,
  ) {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));

    return history.where((point) {
      final createdAt = point.createdAt;
      if (createdAt == null) return true;

      return createdAt.isAfter(cutoff) || createdAt.isAtSameMomentAs(cutoff);
    }).toList();
  }

  // desenvolvido por Miguel Gallinucci - monta os tokens da carteira a partir do historico.
  List<_TokenPosition> _positionsFromTransactions(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final positions = <String, _TokenPosition>{};
    final orderedDocs = [...docs]
      ..sort((a, b) {
        final aDate = _toMillis(a.data()['createdAt']);
        final bDate = _toMillis(b.data()['createdAt']);

        return aDate.compareTo(bDate);
      });

    for (final doc in orderedDocs) {
      final data = doc.data();
      final type = (data['type'] ?? data['tipo'] ?? '')
          .toString()
          .toLowerCase();

      final isPurchase = type == 'compra' || type == 'compra_balcao';
      final isReservedForSale = type == 'oferta_venda';
      final isCanceledOffer = type == 'cancelamento_oferta';

      if (!isPurchase && !isReservedForSale && !isCanceledOffer) {
        continue;
      }

      final startupName = (data['startupName'] ??
              data['nomeStartup'] ??
              data['startup'] ??
              'Startup')
          .toString();
      final key = (data['startupId'] ?? startupName).toString();
      final quantity = _toInt(data['quantity']);
      final tokenPrice = _toDouble(data['tokenPrice']);
      final totalValue = _toDouble(
        data['totalValue'] ?? data['valorTotal'] ?? data['amount'],
      ).abs();
      final reservedCost = _toDouble(data['reservedCost']);

      if (quantity <= 0) {
        continue;
      }

      final current = positions[key];
      var newQuantity = current?.quantity ?? 0;
      var newTotalInvested = current?.totalInvested ?? 0;
      var newTokenPrice = current?.tokenPrice ?? 0;

      if (isPurchase) {
        newQuantity += quantity;
        newTotalInvested += totalValue;
        newTokenPrice = tokenPrice > 0 ? tokenPrice : newTokenPrice;
      } else if (isReservedForSale) {
        final averagePrice =
            newQuantity > 0 ? newTotalInvested / newQuantity : 0;
        final costToRemove = reservedCost > 0
            ? reservedCost
            : averagePrice * quantity;
        newQuantity -= quantity;
        newTotalInvested -= costToRemove;

        if (newQuantity < 0) {
          newQuantity = 0;
        }

        if (newTotalInvested < 0) {
          newTotalInvested = 0;
        }
      } else if (isCanceledOffer) {
        newQuantity += quantity;
        newTotalInvested += reservedCost;
      }

      positions[key] = _TokenPosition(
        startupId: key,
        startupName: startupName,
        sector: (data['sector'] ?? current?.sector ?? '').toString(),
        quantity: newQuantity,
        tokenPrice: newTokenPrice,
        totalInvested: newTotalInvested,
        averagePrice: newQuantity > 0 ? newTotalInvested / newQuantity : 0,
      );
    }

    return positions.values.where((position) => position.quantity > 0).toList()
      ..sort((a, b) => a.startupName.compareTo(b.startupName));
  }

  // desenvolvido por Miguel Gallinucci - abre os detalhes reais do token selecionado.
  void _showTokenDetails(_TokenPosition position) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.45),
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
                            color: AppColors.primary.withValues(alpha: 0.30),
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Detalhes do token',
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
                    'Resumo da sua posicao em ${position.startupName}.',
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
                    child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: _watchStartup(position.startupId),
                      builder: (context, startupSnapshot) {
                        final startupData = startupSnapshot.data?.data() ?? {};
                        final startupName =
                            (startupData['name'] ?? position.startupName)
                                .toString();
                        final firebaseCategories =
                            startupData['categorias'] is List
                                ? List<String>.from(startupData['categorias'])
                                : const <String>[];
                        final sector = firebaseCategories.isNotEmpty
                            ? firebaseCategories.join(' / ')
                            : (startupData['sector'] ?? position.sector)
                                .toString();
                        final currentTokenPrice =
                            _toDouble(startupData['tokenPrice']);
                        final tokenPrice = currentTokenPrice > 0
                            ? currentTokenPrice
                            : position.tokenPrice;
                        final currentValue = position.quantity * tokenPrice;
                        final returnPercent = position.totalInvested > 0
                            ? ((currentValue - position.totalInvested) /
                                    position.totalInvested) *
                                100
                            : 0.0;
                        final isPositive = returnPercent >= 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              startupName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sector.isEmpty ? 'Startup' : sector,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _TokenDetailInfo(
                                    label: 'Voce possui',
                                    value: '${position.quantity} tokens',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _TokenDetailInfo(
                                    label: 'Valor atual',
                                    value: AppFormatters.currency(currentValue),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _TokenDetailInfo(
                                    label: 'Total investido',
                                    value: AppFormatters.currency(
                                      position.totalInvested,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _TokenDetailInfo(
                                    label: 'Rentabilidade',
                                    value:
                                        '${isPositive ? '+' : ''}${returnPercent.toStringAsFixed(1)}%',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _TokenDetailInfo(
                                    label: 'Preco medio',
                                    value: AppFormatters.currency(
                                      position.averagePrice,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _TokenDetailInfo(
                                    label: 'Preco do token',
                                    value: AppFormatters.currency(tokenPrice),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Ultimas 24h',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 180,
                              child:
                                  StreamBuilder<List<_WalletTokenPricePoint>>(
                                stream: _watchTokenPriceHistory(
                                  position.startupId,
                                ),
                                builder: (context, snapshot) {
                                  final chartData = _walletTokenChartData(
                                    position,
                                    snapshot.data ?? const [],
                                    currentTokenPrice: tokenPrice,
                                  );

                                  return _TokenMiniChart(
                                    values: chartData.values,
                                    labels: chartData.labels,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // desenvolvido por Miguel Gallinucci - prepara o grafico de 24h do token da carteira.
  _WalletTokenChartData _walletTokenChartData(
    _TokenPosition position,
    List<_WalletTokenPricePoint> history, {
    required double currentTokenPrice,
  }) {
    final realHistory = _last24HourPriceHistory(history);

    if (realHistory.isNotEmpty) {
      final values = <double>[];
      final labels = <String>[];
      final firstPoint = realHistory.first;

      if (firstPoint.previousPrice != null && firstPoint.previousPrice! > 0) {
        values.add(firstPoint.previousPrice!);
        labels.add('Inicio');
      }

      for (final point in realHistory) {
        values.add(point.price);
        labels.add(_formatHourLabel(point.createdAt));
      }

      if (values.length == 1) {
        values.insert(0, currentTokenPrice);
        labels.insert(0, 'Inicio');
      }

      return _WalletTokenChartData(values: values, labels: labels);
    }

    final currentPrice = currentTokenPrice > 0
        ? currentTokenPrice
        : (position.tokenPrice > 0 ? position.tokenPrice : position.averagePrice);

    if (currentPrice <= 0 && position.averagePrice <= 0) {
      return const _WalletTokenChartData(
        values: [0, 0],
        labels: ['Inicio', 'Hoje'],
      );
    }

    return _WalletTokenChartData(
      values: [
        currentPrice,
        currentPrice,
      ],
      labels: const ['Inicio', 'Hoje'],
    );
  }

  String _formatHourLabel(DateTime? date) {
    if (date == null) return 'Agora';

    return '${date.hour.toString().padLeft(2, '0')}h';
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
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _walletService.watchCurrentUserWallet(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 120),
                        child: AppLoading(
                          message: 'Carregando sua carteira...',
                        ),
                      );
                    }

                    if (userSnapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 120),
                        child: AppErrorState(
                          title: 'Ops!',
                          message: 'Erro ao carregar dados da carteira.',
                        ),
                      );
                    }

                    final userData = userSnapshot.data?.data() ?? {};
                    final balance = _toDouble(userData['saldoFicticio']);

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _walletService.watchUserTransactions(),
                      builder: (context, transactionsSnapshot) {
                        final positions = _positionsFromTransactions(
                          transactionsSnapshot.data?.docs ?? [],
                        );
                        final totalInvested = positions.fold<double>(
                          0,
                          (total, position) => total + position.totalInvested,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PageHeader(
                              title: 'Minha carteira',
                              onBack: () => Navigator.pop(context),
                            ),
                            WalletSummarySection(
                              availableBalance:
                                  AppFormatters.currency(balance),
                              totalInvested:
                                  AppFormatters.currency(totalInvested),
                              startupsCount: positions.length.toString(),
                              onAddBalance: _showAddBalanceModal,
                            ),
                            const SizedBox(height: 26),
                            const Text(
                              'Meus tokens',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPositionsSection(
                              transactionsSnapshot,
                              positions,
                            ),
                            const SizedBox(height: 26),
                            const Text(
                              'Historico',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTransactionsSection(),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionsSection(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
    List<_TokenPosition> positions,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (snapshot.hasError) {
      return const _EmptyStateCard(
        icon: Icons.error_outline_rounded,
        title: 'Erro ao carregar tokens',
        description: 'Nao foi possivel buscar os tokens da carteira.',
      );
    }

    if (positions.isEmpty) {
      return const _EmptyStateCard(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Nenhum token comprado ainda',
        description:
            'Quando voce investir em uma startup, os tokens aparecerao aqui.',
      );
    }

    return Column(
      children: positions.map((position) {
        return _TokenPositionCard(
          position: position,
          onTap: () => _showTokenDetails(position),
        );
      }).toList(),
    );
  }

  // desenvolvido por Miguel Gallinucci - exibe o historico financeiro da carteira.
  // Constrói o histórico de movimentações lendo da coleção 'transactions'.
  // As transações são criadas exclusivamente pelo backend (Cloud Functions).
  // A regra do Firestore 'allow write: if false' para transações garante que
  // o histórico não pode ser falsificado via client-side.
  Widget _buildTransactionsSection() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _walletService.watchUserTransactions(),
      builder: (context, transactionSnapshot) {
        if (transactionSnapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (transactionSnapshot.hasError) {
          return const _EmptyStateCard(
            icon: Icons.error_outline_rounded,
            title: 'Erro ao carregar historico',
            description:
                'Nao foi possivel buscar as movimentacoes da carteira.',
          );
        }

        final transactions = transactionSnapshot.data?.docs ?? [];
        transactions.sort((a, b) {
          final aDate = a.data()['createdAt'];
          final bDate = b.data()['createdAt'];

          if (aDate is! Timestamp && bDate is! Timestamp) return 0;
          if (aDate is! Timestamp) return 1;
          if (bDate is! Timestamp) return -1;

          return bDate.compareTo(aDate);
        });

        if (transactions.isEmpty) {
          return const _EmptyStateCard(
            icon: Icons.history_rounded,
            title: 'Nenhuma movimentacao registrada',
            description: 'Os aportes, compras e vendas aparecerao aqui.',
          );
        }

        return Column(
          children: transactions.map((transactionDoc) {
            final data = transactionDoc.data();
            final type = (data['type'] ?? data['tipo'] ?? '')
                .toString()
                .toLowerCase();
            final startupName = data['startupName'] ??
                data['nomeStartup'] ??
                data['startup'] ??
                '';

            var title = data['title'] ??
                data['descricao'] ??
                data['description'] ??
                (type == 'aporte_simulado'
                    ? 'Adicao de saldo'
                    : type == 'compra'
                        ? 'Compra de tokens'
                        : type == 'venda'
                            ? 'Venda de tokens'
                            : 'Movimentacao');

            var description = data['description'] ??
                data['subtitle'] ??
                (type == 'aporte_simulado'
                    ? 'Credito interno'
                    : startupName.toString().isNotEmpty
                        ? startupName
                        : 'Movimentacao');

            if (type == 'aporte_simulado') {
              title = 'Credito adicionado';
              description = 'Credito adicionado';
            }

            final rawAmount = data['amount'] ??
                data['valorTotal'] ??
                data['totalValue'] ??
                data['valor'] ??
                0;
            final amount = _toDouble(rawAmount);
            final createdAt = data['createdAt'] as Timestamp?;
            final isSale = type == 'venda' || type == 'venda_token';
            final isCredit =
                type == 'aporte_simulado' || type == 'credito' || isSale;

            return WalletHistoryItem(
              title: title.toString(),
              subtitle: description.toString(),
              value: isCredit
                  ? AppFormatters.currency(amount.abs())
                  : AppFormatters.negativeCurrency(amount.abs()),
              date: AppFormatters.formatDate(createdAt),
              isCredit: isCredit,
            );
          }).toList(),
        );
      },
    );
  }
}

class _TokenPosition {
  final String startupId;
  final String startupName;
  final String sector;
  final int quantity;
  final double tokenPrice;
  final double totalInvested;
  final double averagePrice;

  const _TokenPosition({
    required this.startupId,
    required this.startupName,
    required this.sector,
    required this.quantity,
    required this.tokenPrice,
    required this.totalInvested,
    required this.averagePrice,
  });
}

class _WalletTokenPricePoint {
  final double price;
  final double? previousPrice;
  final DateTime? createdAt;

  const _WalletTokenPricePoint({
    required this.price,
    this.previousPrice,
    this.createdAt,
  });

  factory _WalletTokenPricePoint.fromMap(Map<String, dynamic> data) {
    return _WalletTokenPricePoint(
      price: _toDouble(data['price']),
      previousPrice: _toNullableDouble(data['previousPrice']),
      createdAt: _toDateTime(data['createdAt']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    }

    return 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.'));
    }

    return null;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    return null;
  }
}

class _WalletTokenChartData {
  final List<double> values;
  final List<String> labels;

  const _WalletTokenChartData({
    required this.values,
    required this.labels,
  });
}

class _TokenPositionCard extends StatelessWidget {
  final _TokenPosition position;
  final VoidCallback onTap;

  const _TokenPositionCard({
    required this.position,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    position.startupName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${position.quantity} token(s)',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              AppFormatters.currency(position.totalInvested),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_up_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenDetailInfo extends StatelessWidget {
  final String label;
  final String value;

  const _TokenDetailInfo({
    required this.label,
    required this.value,
  });

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

class _TokenMiniChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const _TokenMiniChart({
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TokenMiniChartPainter(
        values: values,
        labels: labels,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _TokenMiniChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  const _TokenMiniChartPainter({
    required this.values,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || labels.isEmpty) return;

    final itemCount =
        values.length < labels.length ? values.length : labels.length;
    if (itemCount == 0) return;

    const leftPadding = 48.0;
    const rightPadding = 12.0;
    const topPadding = 10.0;
    const bottomPadding = 28.0;

    final chartHeight = size.height - topPadding - bottomPadding;
    final chartBottom = topPadding + chartHeight;
    final chartWidth = size.width - leftPadding - rightPadding;
    final visibleValues = values.take(itemCount).toList();
    final minValue = visibleValues.reduce((a, b) => a < b ? a : b);
    final maxValue = visibleValues.reduce((a, b) => a > b ? a : b);
    final rawRange = maxValue - minValue;
    final padding = rawRange == 0 ? maxValue.abs() * 0.08 : rawRange * 0.18;
    final chartMin = minValue - padding;
    final chartMax = maxValue + padding;
    final range = (chartMax - chartMin) == 0 ? 1.0 : chartMax - chartMin;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x3334D399),
          Color(0x0034D399),
        ],
      ).createShader(
        Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight),
      );

    for (int i = 0; i <= 3; i++) {
      final y = topPadding + (chartHeight * i / 3);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    final points = <Offset>[];
    for (int i = 0; i < itemCount; i++) {
      final x = itemCount == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + (chartWidth / (itemCount - 1)) * i;
      final normalized = (values[i] - chartMin) / range;
      final y = chartBottom - (normalized * chartHeight);
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chartBottom)
      ..lineTo(points.first.dx, chartBottom)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    for (final point in points) {
      canvas.drawCircle(
        point,
        4.2,
        Paint()
          ..color = const Color(0xFF04111D)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        point,
        2.8,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.fill,
      );
    }

    for (int i = 0; i < itemCount; i++) {
      if (i != 0 && i != itemCount - 1 && i % 2 != 0) continue;
      _paintText(
        canvas,
        labels[i],
        Offset(points[i].dx - 18, chartBottom + 10),
      );
    }
  }

  void _paintText(Canvas canvas, String text, Offset offset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 40);

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _TokenMiniChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyStateCard({
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
