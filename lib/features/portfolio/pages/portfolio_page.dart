// Página de Portfólio (Carteira)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../services/portfolio_service.dart';

/// Widget principal da página de portfólio
/// Responsável por exibir a carteira de investimentos do usuário
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

/// Estado da página de portfólio
/// Gerencia a inicialização, formatação de dados e exibição de modais
class _PortfolioPageState extends State<PortfolioPage> {
  /// Serviço responsável por operações do portfólio no Firestore
  final PortfolioService _portfolioService = PortfolioService();

  /// Flag para indicar se a página está em processo de inicialização
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializePortfolio();
  }

  /// Inicializa o portfólio garantindo que o campo de saldo fictício
  /// existe no documento do usuário no Firestore.
  /// Se houver erro, exibe um SnackBar com a mensagem de erro.
  Future<void> _initializePortfolio() async {
    try {
      await _portfolioService.ensurePortfolioFieldExists();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar carteira: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  /// Formata um valor numérico para o padrão de moeda brasileira (R$)
  /// Exemplo: 1000.50 -> R$ 1000,50
  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatNegativeCurrency(double value) {
    final positiveValue = value.abs();
    return '-R\$ ${positiveValue.toStringAsFixed(2).replaceAll('.', ',')}';
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
    List<QueryDocumentSnapshot<Map<String, dynamic>>> transactions,
  ) {
    final positions = <String, _TokenPosition>{};

    for (final transactionDoc in transactions) {
      final data = transactionDoc.data();
      final type = (data['type'] ?? data['tipo'] ?? '')
          .toString()
          .toLowerCase();

      if (type != 'compra') {
        continue;
      }

      final startupName =
          (data['startupName'] ??
                  data['nomeStartup'] ??
                  data['startup'] ??
                  'Startup')
              .toString();

      final startupId = (data['startupId'] ?? startupName)
          .toString()
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');

      final quantity = _toInt(data['quantity']);
      final tokenPrice = _toDouble(data['tokenPrice']);
      final totalValue = _toDouble(data['totalValue'] ?? data['amount']).abs();

      if (quantity <= 0) {
        continue;
      }

      final current = positions[startupId];
      final newQuantity = (current?.quantity ?? 0) + quantity;
      final newTotalInvested = (current?.totalInvested ?? 0) + totalValue;

      positions[startupId] = _TokenPosition(
        startupName: startupName,
        sector: (data['sector'] ?? current?.sector ?? '').toString(),
        quantity: newQuantity,
        tokenPrice: tokenPrice > 0 ? tokenPrice : current?.tokenPrice ?? 0,
        totalInvested: newTotalInvested,
      );
    }

    return positions.values.toList()
      ..sort((a, b) => a.startupName.compareTo(b.startupName));
  }

  /// Formata uma data do Firestore para o padrão brasileiro (DD/MM/YYYY)
  /// Se o timestamp for null, retorna 'Agora'
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Agora';
    }

    final date = timestamp.toDate();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  /// Exibe um modal para o usuário adicionar saldo simulado à carteira
  /// Permite seleção rápida de valores predefinidos ou entrada customizada
  /// Realiza validação do valor inserido antes de confirmar
  Future<void> _showAddBalanceModal() async {
    final selectedAmount = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: const Color(0xFF071A2B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final amountController = TextEditingController();

        void submitTypedValue() {
          final rawValue = amountController.text
              .replaceAll('.', '')
              .replaceAll(',', '.')
              .trim();

          final amount = double.tryParse(rawValue);

          if (amount == null || amount <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Digite um valor válido.')),
            );
            return;
          }

          Navigator.pop(context, amount);
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adicionar saldo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esse valor será usado apenas para compras de tokens no aplicativo.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _QuickAmountButton(
                      label: 'R\$ 1.000',
                      onTap: () => Navigator.pop(context, 1000.0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAmountButton(
                      label: 'R\$ 5.000',
                      onTap: () => Navigator.pop(context, 5000.0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAmountButton(
                      label: 'R\$ 10.000',
                      onTap: () => Navigator.pop(context, 10000.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => submitTypedValue(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Ou digite outro valor',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixText: 'R\$ ',
                  prefixStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.04),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: submitTypedValue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Confirmar saldo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedAmount == null) {
      return;
    }

    try {
      await _portfolioService.addSimulatedBalance(selectedAmount);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saldo de ${_formatCurrency(selectedAmount)} adicionado.',
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

  /// Constrói a interface da página de portfólio
  /// Se está inicializando, exibe carregamento
  /// Caso contrário, exibe gradiente de fundo, saldo, tokens e histórico de transações
  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Color(0xFF04111D),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Center(
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _portfolioService.watchCurrentUserPortfolio(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 120),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (userSnapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 120),
                        child: Text(
                          'Erro ao carregar dados da carteira.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final userData = userSnapshot.data?.data() ?? {};
                    final rawBalance = userData['saldoFicticio'] ?? 0;
                    final balance = rawBalance is num
                        ? rawBalance.toDouble()
                        : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Minha carteira',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Gerencie seu saldo, acompanhe seus tokens e visualize suas movimentações.',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Resumo da carteira',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _showAddBalanceModal,
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Adicionar saldo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: _SummaryCard(
                                  label: 'Saldo disponível',
                                  value: _formatCurrency(balance),
                                  isHighlight: true,
                                ),
                              ),
                              const SizedBox(height: 12),
                              StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>
                              >(
                                stream: _portfolioService
                                    .watchUserTransactions(),
                                builder: (context, transactionSnapshot) {
                                  final positions = _buildTokenPositions(
                                    transactionSnapshot.data?.docs ?? [],
                                  );
                                  final totalInvested = positions.fold<double>(
                                    0,
                                    (total, position) =>
                                        total + position.totalInvested,
                                  );

                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _SummaryCard(
                                          label: 'Total investido',
                                          value: _formatCurrency(totalInvested),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _SummaryCard(
                                          label: 'Startups',
                                          value: positions.length.toString(),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
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
                        if (DateTime.now().microsecondsSinceEpoch < 0)
                          const _EmptyStateCard(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Nenhum token comprado ainda',
                            description:
                                'Quando você investir em uma startup, os tokens aparecerão aqui.',
                          ),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _portfolioService.watchUserTransactions(),
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
                                title: 'Erro ao carregar tokens',
                                description:
                                    'NÃ£o foi possÃ­vel buscar os tokens da carteira.',
                              );
                            }

                            final positions = _buildTokenPositions(
                              transactionSnapshot.data?.docs ?? [],
                            );

                            if (positions.isEmpty) {
                              return const _EmptyStateCard(
                                icon: Icons.account_balance_wallet_outlined,
                                title: 'Nenhum token comprado ainda',
                                description:
                                    'Quando vocÃª investir em uma startup, os tokens aparecerÃ£o aqui.',
                              );
                            }

                            return Column(
                              children: positions
                                  .map(
                                    (position) => _TokenPositionCard(
                                      position: position,
                                      formatCurrency: _formatCurrency,
                                      onTap: () =>
                                          _showTokenDetailsSheet(position),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
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
                          stream: _portfolioService.watchUserTransactions(),
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

                              if (aDate is! Timestamp && bDate is! Timestamp) {
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

                                final type =
                                    (data['type'] ?? data['tipo'] ?? '')
                                        .toString()
                                        .toLowerCase();

                                final startupName =
                                    data['startupName'] ??
                                    data['nomeStartup'] ??
                                    data['startup'] ??
                                    '';

                                final title =
                                    data['title'] ??
                                    data['descricao'] ??
                                    data['description'] ??
                                    (type == 'aporte_simulado'
                                        ? 'Adição de saldo'
                                        : type == 'compra'
                                        ? 'Compra de tokens'
                                        : type == 'venda'
                                        ? 'Venda de tokens'
                                        : 'Movimentação');

                                final description =
                                    data['description'] ??
                                    data['subtitle'] ??
                                    (type == 'aporte_simulado'
                                        ? 'Crédito interno'
                                        : startupName.toString().isNotEmpty
                                        ? startupName
                                        : 'Movimentação');

                                final rawAmount =
                                    data['amount'] ??
                                    data['valorTotal'] ??
                                    data['totalValue'] ??
                                    data['valor'] ??
                                    0;

                                final amount = rawAmount is num
                                    ? rawAmount.toDouble()
                                    : 0.0;

                                final createdAt =
                                    data['createdAt'] as Timestamp?;

                                final bool isSale =
                                    type == 'venda' || type == 'venda_token';

                                final bool isCredit =
                                    type == 'aporte_simulado' ||
                                    type == 'credito' ||
                                    isSale;

                                return _TransactionCard(
                                  title: title
                                      .toString()
                                      .replaceAll('simulado', '')
                                      .trim(),
                                  subtitle: description
                                      .toString()
                                      .replaceAll('simulado', '')
                                      .trim(),
                                  value: isCredit
                                      ? _formatCurrency(amount.abs())
                                      : _formatNegativeCurrency(amount.abs()),
                                  date: _formatDate(createdAt),
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

  void _showTokenDetailsSheet(_TokenPosition position) {
    final averagePrice = position.quantity == 0
        ? 0.0
        : position.totalInvested / position.quantity;

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
                                value: _formatCurrency(position.totalInvested),
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
                                value: _formatCurrency(averagePrice),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TokenDetailInfo(
                                label: 'Preco do token',
                                value: _formatCurrency(position.tokenPrice),
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
                        Container(
                          width: double.infinity,
                          height: 260,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: _TokenMiniChart(
                            values: _tokenChartValues(position, averagePrice),
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

  List<double> _tokenChartValues(_TokenPosition position, double averagePrice) {
    final currentPrice = position.tokenPrice > 0
        ? position.tokenPrice
        : averagePrice;

    if (currentPrice <= 0 && averagePrice <= 0) {
      return const [0, 0, 0, 0, 0, 0];
    }

    final startPrice = averagePrice > 0 ? averagePrice : currentPrice;
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
}

class _TokenPosition {
  final String startupName;
  final String sector;
  final int quantity;
  final double tokenPrice;
  final double totalInvested;

  const _TokenPosition({
    required this.startupName,
    required this.sector,
    required this.quantity,
    required this.tokenPrice,
    required this.totalInvested,
  });
}

class _TokenPositionCard extends StatelessWidget {
  final _TokenPosition position;
  final String Function(double value) formatCurrency;
  final VoidCallback onTap;

  const _TokenPositionCard({
    required this.position,
    required this.formatCurrency,
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
                  formatCurrency(position.totalInvested),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(position.tokenPrice),
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

  const _TokenDetailInfo({required this.label, required this.value});

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

  const _TokenMiniChart({required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    return _TokenLineChart(values: values, labels: labels);
  }
}

class _TokenLineChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;

  const _TokenLineChart({required this.values, required this.labels});

  @override
  State<_TokenLineChart> createState() => _TokenLineChartState();
}

class _TokenLineChartState extends State<_TokenLineChart> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant _TokenLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.values != widget.values ||
        oldWidget.labels != widget.labels) {
      _selectedIndex = null;
    }
  }

  void _selectNearestPoint(Offset localPosition, double width) {
    final itemCount = widget.values.length < widget.labels.length
        ? widget.values.length
        : widget.labels.length;

    if (itemCount == 0) return;

    const leftPadding = 64.0;
    const rightPadding = 22.0;
    final availableWidth = width - leftPadding - rightPadding;

    if (availableWidth <= 0) return;

    final rawIndex = itemCount == 1
        ? 0
        : ((localPosition.dx - leftPadding) / availableWidth * (itemCount - 1))
              .round();

    setState(() {
      _selectedIndex = rawIndex.clamp(0, itemCount - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            _selectNearestPoint(details.localPosition, constraints.maxWidth);
          },
          onHorizontalDragStart: (details) {
            _selectNearestPoint(details.localPosition, constraints.maxWidth);
          },
          onHorizontalDragUpdate: (details) {
            _selectNearestPoint(details.localPosition, constraints.maxWidth);
          },
          child: CustomPaint(
            painter: _TokenLineChartPainter(
              values: widget.values,
              labels: widget.labels,
              selectedIndex: _selectedIndex,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _TokenLineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final int? selectedIndex;

  const _TokenLineChartPainter({
    required this.values,
    required this.labels,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || labels.isEmpty) return;

    final itemCount = values.length < labels.length
        ? values.length
        : labels.length;
    final visibleValues = values.take(itemCount).toList();
    if (itemCount == 0) return;

    const leftPadding = 64.0;
    const rightPadding = 22.0;
    const topPadding = 14.0;
    const bottomPadding = 34.0;

    final chartHeight = size.height - topPadding - bottomPadding;
    final chartBottom = topPadding + chartHeight;
    final availableWidth = size.width - leftPadding - rightPadding;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.2;

    final linePaint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 3.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader =
          const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x3334D399), Color(0x0034D399)],
          ).createShader(
            Rect.fromLTWH(leftPadding, topPadding, availableWidth, chartHeight),
          );

    final pointGlowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = const Color(0xFF04111D)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final minValue = visibleValues.reduce((a, b) => a < b ? a : b);
    final maxValue = visibleValues.reduce((a, b) => a > b ? a : b);
    final rawRange = maxValue - minValue;
    final padding = rawRange == 0 ? maxValue.abs() * 0.08 : rawRange * 0.18;
    final chartMin = minValue - padding;
    final chartMax = maxValue + padding;
    final range = (chartMax - chartMin) == 0 ? 1.0 : (chartMax - chartMin);

    for (int i = 0; i <= 4; i++) {
      final y = topPadding + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      final value = chartMax - (range * i / 4);
      _paintText(
        canvas: canvas,
        text: 'R\$ ${_formatPriceAxisValue(value)}',
        x: 0,
        y: y - 8,
        maxWidth: leftPadding - 8,
        color: AppColors.textSecondary,
        fontSize: 10.5,
        textAlign: TextAlign.right,
      );
    }

    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, chartBottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(leftPadding, chartBottom),
      Offset(size.width - rightPadding, chartBottom),
      axisPaint,
    );

    final points = <Offset>[];
    for (int i = 0; i < itemCount; i++) {
      final x = itemCount == 1
          ? leftPadding + availableWidth / 2
          : leftPadding + (availableWidth / (itemCount - 1)) * i;
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

    final activeIndex = (selectedIndex ?? itemCount - 1).clamp(
      0,
      itemCount - 1,
    );
    final activePoint = points[activeIndex];

    canvas.drawLine(
      Offset(activePoint.dx, chartBottom),
      activePoint,
      Paint()
        ..color = AppColors.primaryLight.withValues(alpha: 0.28)
        ..strokeWidth = 1.2,
    );

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isActive = i == activeIndex;
      canvas.drawCircle(point, isActive ? 8 : 6.5, pointGlowPaint);
      canvas.drawCircle(point, isActive ? 5.4 : 4.6, pointBorderPaint);
      canvas.drawCircle(point, isActive ? 3.8 : 3.2, pointPaint);
    }

    _paintValueBubble(
      canvas: canvas,
      text:
          '${labels[activeIndex]}  R\$ ${_formatSelectedPriceValue(values[activeIndex])}',
      anchor: activePoint,
      size: size,
    );

    final labelStep = itemCount > 8 ? 2 : 1;
    for (int i = 0; i < itemCount; i++) {
      if (i != itemCount - 1 && i % labelStep != 0) continue;
      if (itemCount > 8 && i == itemCount - 2) continue;

      final label = labels[i];
      final point = points[i];
      const labelWidth = 48.0;
      final labelX = (point.dx - labelWidth / 2).clamp(
        0.0,
        size.width - labelWidth,
      );

      _paintText(
        canvas: canvas,
        text: label,
        x: labelX,
        y: chartBottom + 12,
        maxWidth: labelWidth,
        color: i == activeIndex
            ? AppColors.primaryLight
            : AppColors.textSecondary,
        fontSize: 11,
        textAlign: TextAlign.center,
      );
    }
  }

  void _paintValueBubble({
    required Canvas canvas,
    required String text,
    required Offset anchor,
    required Size size,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    const horizontalPadding = 8.0;
    const verticalPadding = 5.0;
    final width = textPainter.width + horizontalPadding * 2;
    final height = textPainter.height + verticalPadding * 2;

    var left = anchor.dx - width / 2;
    var top = anchor.dy - height - 10;

    if (left < 0) left = 0;
    if (left + width > size.width) left = size.width - width;
    if (top < 0) top = anchor.dy + 10;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, width, height),
      const Radius.circular(12),
    );

    canvas.drawRRect(rect, Paint()..color = const Color(0xFF102235));
    canvas.drawRRect(
      rect,
      Paint()
        ..color = AppColors.primaryLight.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    textPainter.paint(
      canvas,
      Offset(left + horizontalPadding, top + verticalPadding),
    );
  }

  void _paintText({
    required Canvas canvas,
    required String text,
    required double x,
    required double y,
    required double maxWidth,
    required Color color,
    required double fontSize,
    TextAlign textAlign = TextAlign.left,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);

    var paintX = x;

    if (textAlign == TextAlign.center) {
      paintX = x + (maxWidth - textPainter.width) / 2;
    } else if (textAlign == TextAlign.right) {
      paintX = x + maxWidth - textPainter.width;
    }

    textPainter.paint(canvas, Offset(paintX, y));
  }

  String _formatPriceAxisValue(double value) {
    if (value.abs() < 0.1) {
      return value.toStringAsFixed(3).replaceAll('.', ',');
    }

    if (value.abs() < 1) {
      return value.toStringAsFixed(2).replaceAll('.', ',');
    }

    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _formatSelectedPriceValue(double value) {
    if (value.abs() < 0.1) {
      return value.toStringAsFixed(3).replaceAll('.', ',');
    }

    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  bool shouldRepaint(covariant _TokenLineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.labels != labels ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

/// Widget auxiliar que exibe resumo da carteira com label e valor
/// Usado para mostrar informações como saldo disponível, total investido, etc.
class _SummaryCard extends StatelessWidget {
  /// Rótulo da informação
  final String label;

  /// Valor a ser exibido
  final String value;

  /// Define se o card deve ter destaque especial (border e texto em cor primária)
  final bool isHighlight;

  /// Construtor do card de resumo
  const _SummaryCard({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  /// Constrói o card com layout em coluna
  /// Aplica estilos especiais se isHighlight for true
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isHighlight
              ? AppColors.primary.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.04),
        ),
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
            style: TextStyle(
              color: isHighlight ? AppColors.primaryLight : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão auxiliar para rápida seleção de valores de saldo
/// Exibido no modal de adição de saldo
class _QuickAmountButton extends StatelessWidget {
  /// Texto do botão exibindo o valor (ex: "R$ 1.000")
  final String label;

  /// Callback executado quando o botão é pressionado
  final VoidCallback? onTap;

  /// Construtor do botão de valor rápido
  const _QuickAmountButton({required this.label, required this.onTap});

  /// Constrói um botão com contorno e estilo primário
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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

/// Widget que exibe uma transação/movimentação no histórico
/// Mostra informações da movimentação como tipo, data e valor
class _TransactionCard extends StatelessWidget {
  /// Título da transação (ex: "Adição de saldo simulado")
  final String title;

  /// Subtítulo/tipo da transação (ex: "Crédito interno")
  final String subtitle;

  /// Valor da transação formatado em moeda
  final String value;

  /// Data da transação formatada
  final String date;

  /// Indica se a transação é de crédito ou débito
  final bool isCredit;

  /// Construtor do card de transação
  const _TransactionCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.date,
    required this.isCredit,
  });

  /// Retorna o ícone apropriado baseado no tipo de transação
  /// Crédito interno usa ícone de cartão, outros usam ícone de recibo
  IconData get _icon {
    if (isCredit) {
      return Icons.add_card_rounded;
    }

    return Icons.receipt_long_rounded;
  }

  /// Constrói o card de transação com ícone, informações e data
  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Icon(_icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$subtitle • $date',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              color: isCredit ? AppColors.primaryLight : AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
