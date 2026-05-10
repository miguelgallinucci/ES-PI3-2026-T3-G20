// Página de Carteira
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../services/wallet_service.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/page_header.dart';
import '../widgets/wallet_history_item.dart';
import '../widgets/wallet_summary_section.dart';
import '../widgets/wallet_deposit_sheet.dart';
import '../../../core/utils/app_formatters.dart';

/// Widget principal da página de portfólio
/// Responsável por exibir a carteira de investimentos do usuário
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

/// Estado da página de portfólio
/// Gerencia a inicialização, formatação de dados e exibição de modais
class _WalletPageState extends State<WalletPage> {
  /// Serviço responsável por operações do portfólio no Firestore
  final WalletService _walletService = WalletService();


  @override
  void initState() {
    super.initState();
  }



  Future<void> _showAddBalanceModal() async {
    final selectedAmount = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: const Color(0xFF071A2B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) => const WalletDepositSheet(),
    );

    if (selectedAmount == null) {
      return;
    }

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
        SnackBar(
          content: Text('Erro ao adicionar saldo: $error'),
        ),
      );
    }
  }

  /// Constrói a interface da página de portfólio
  /// Se está inicializando, exibe carregamento
  /// Caso contrário, exibe gradiente de fundo, saldo, tokens e histórico de transações
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Center(
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
                    final rawBalance = userData['saldoFicticio'] ?? 0;
                    final balance =
                    rawBalance is num ? rawBalance.toDouble() : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageHeader(
                          title: 'Minha carteira',
                          onBack: () => Navigator.pop(context),
                        ),
                        WalletSummarySection(
                          availableBalance: AppFormatters.currency(balance),
                          totalInvested: 'R\$ 0,00',
                          startupsCount: '0',
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
                        const _EmptyStateCard(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Nenhum token comprado ainda',
                          description:
                          'Quando você investir em uma startup, os tokens aparecerão aqui.',
                        ),
                        const SizedBox(height: 26),
                        const Text(
                          'Histórico',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _walletService.watchUserTransactions(),
                          builder: (context, transactionSnapshot) {
                            if (transactionSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }

                            if (transactionSnapshot.hasError) {
                              return const _EmptyStateCard(
                                icon: Icons.error_outline_rounded,
                                title: 'Erro ao carregar histórico',
                                description:
                                'Não foi possível buscar as movimentações da carteira.',
                              );
                            }

                            final transactions =
                                transactionSnapshot.data?.docs ?? [];

                            transactions.sort((a, b) {
                              final aData = a.data();
                              final bData = b.data();

                              final aDate = aData['createdAt'];
                              final bDate = bData['createdAt'];

                              if (aDate is! Timestamp &&
                                  bDate is! Timestamp) {
                                return 0;
                              }

                              if (aDate is! Timestamp) {
                                return 1;
                              }

                              if (bDate is! Timestamp) {
                                return -1;
                              }

                              return bDate.compareTo(aDate);
                            });

                            if (transactions.isEmpty) {
                              return const _EmptyStateCard(
                                icon: Icons.history_rounded,
                                title: 'Nenhuma movimentação registrada',
                                description:
                                'Os aportes, compras e vendas aparecerão aqui.',
                              );
                            }

                            return Column(
                              children: transactions.map((transactionDoc) {
                                final data = transactionDoc.data();

                                final type = (data['type'] ?? data['tipo'] ?? '').toString().toLowerCase();

                                final startupName = data['startupName'] ??
                                    data['nomeStartup'] ??
                                    data['startup'] ??
                                    '';

                                final title = data['title'] ??
                                    data['descricao'] ??
                                    data['description'] ??
                                    (type == 'aporte_simulado'
                                        ? 'Adição de saldo'
                                        : type == 'compra'
                                            ? 'Compra de tokens'
                                            : type == 'venda'
                                                ? 'Venda de tokens'
                                                : 'Movimentação');

                                final description = data['description'] ??
                                    data['subtitle'] ??
                                    (type == 'aporte_simulado'
                                        ? 'Crédito interno'
                                        : startupName.toString().isNotEmpty
                                            ? startupName
                                            : 'Movimentação');

                                final rawAmount = data['amount'] ??
                                    data['valorTotal'] ??
                                    data['totalValue'] ??
                                    data['valor'] ??
                                    0;

                                final amount = rawAmount is num ? rawAmount.toDouble() : 0.0;

                                final createdAt = data['createdAt'] as Timestamp?;

                                final bool isSale =
                                    type == 'venda' ||
                                    type == 'venda_token';

                                final bool isCredit =
                                    type == 'aporte_simulado' ||
                                    type == 'credito' ||
                                    isSale;

                                return WalletHistoryItem(
                                  title: title.toString().replaceAll('simulado', '').trim(),
                                  subtitle: description.toString().replaceAll('simulado', '').trim(),
                                  value: isCredit
                                      ? AppFormatters.currency(amount.abs())
                                      : AppFormatters.negativeCurrency(amount.abs()),
                                  date: AppFormatters.formatDate(createdAt),
                                  isCredit: isCredit,
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
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
}



/// Widget auxiliar para exibir estado vazio de forma amigável
/// Utilizado quando não há tokens comprados, histórico, ou ocorreu erro
class _EmptyStateCard extends StatelessWidget {
  /// Ícone a ser exibido
  final IconData icon;
  /// Título da mensagem
  final String title;
  /// Descrição adicional
  final String description;

  /// Construtor do card de estado vazio
  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  /// Constrói o card com ícone, título e descrição em layout centralizado
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
          Icon(
            icon,
            color: AppColors.primary,
            size: 34,
          ),
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