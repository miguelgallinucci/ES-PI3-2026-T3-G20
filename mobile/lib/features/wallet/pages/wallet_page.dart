import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/page_header.dart';
import '../../startup/widgets/startup_token_overview_card.dart';
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
    if (value == null) return 0;
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
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  List<_TokenPosition> _buildTokenPositions(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.map((doc) {
      final data = doc.data();
      final quantity = _toInt(data['quantity']);
      final totalInvested = _toDouble(data['totalInvested']);
      final averagePrice = _toDouble(data['averagePrice']);

      return _TokenPosition(
        startupName: (data['startupName'] ?? 'Startup').toString(),
        sector: (data['sector'] ?? '').toString(),
        quantity: quantity,
        tokenPrice: _toDouble(data['tokenPrice']),
        totalInvested: totalInvested,
        averagePrice: averagePrice > 0
            ? averagePrice
            : quantity > 0
                ? totalInvested / quantity
                : 0,
      );
    }).where((position) {
      return position.quantity > 0;
    }).toList()
      ..sort((a, b) => a.startupName.compareTo(b.startupName));
  }

  List<double> _tokenChartValues(_TokenPosition position) {
    final currentPrice = position.tokenPrice > 0
        ? position.tokenPrice
        : position.averagePrice;

    if (currentPrice <= 0 && position.averagePrice <= 0) {
      return const [0, 0, 0, 0, 0, 0, 0];
    }

    final startPrice = position.averagePrice > 0
        ? position.averagePrice
        : currentPrice;
    final middlePrice = (startPrice + currentPrice) / 2;

    return [
      startPrice * 0.94,
      startPrice * 0.98,
      middlePrice,
      middlePrice * 1.03,
      currentPrice * 0.99,
      currentPrice * 1.01,
      currentPrice,
    ];
  }

  void _showTokenDetailsSheet(_TokenPosition position) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
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
                          color: AppColors.primaryLight,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          position.startupName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          position.sector.isEmpty ? 'Startup' : position.sector,
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
                                label: 'Total investido',
                                value: AppFormatters.currency(
                                  position.totalInvested,
                                ),
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
                                value: AppFormatters.currency(
                                  position.tokenPrice,
                                ),
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
                          height: 260,
                          child: StartupLineChart(
                            values: _tokenChartValues(position),
                            labels: const [
                              '00h',
                              '04h',
                              '08h',
                              '12h',
                              '16h',
                              '20h',
                              '24h',
                            ],
                          ),
                        ),
                      ],
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
                      stream: _walletService.watchUserPositions(),
                      builder: (context, positionSnapshot) {
                        final positions = _buildTokenPositions(
                          positionSnapshot.data?.docs ?? [],
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
                            _buildPositionsSection(positionSnapshot, positions),
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
          onTap: () => _showTokenDetailsSheet(position),
        );
      }).toList(),
    );
  }

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
  final String startupName;
  final String sector;
  final int quantity;
  final double tokenPrice;
  final double totalInvested;
  final double averagePrice;

  const _TokenPosition({
    required this.startupName,
    required this.sector,
    required this.quantity,
    required this.tokenPrice,
    required this.totalInvested,
    required this.averagePrice,
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
                    '${position.quantity} token(s) - ${position.sector.isEmpty ? 'Startup' : position.sector}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency(position.totalInvested),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.currency(position.tokenPrice),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
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
