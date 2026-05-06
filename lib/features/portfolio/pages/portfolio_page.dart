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
        SnackBar(
          content: Text('Erro ao carregar carteira: $error'),
        ),
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
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
              const SnackBar(
                content: Text('Digite um valor válido.'),
              ),
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
                  labelStyle: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                  prefixText: 'R\$ ',
                  prefixStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.04),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                    ),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Color(0xFF04111D),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

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
                    final balance =
                    rawBalance is num ? rawBalance.toDouble() : 0.0;

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
                              const Row(
                                children: [
                                  Expanded(
                                    child: _SummaryCard(
                                      label: 'Total investido',
                                      value: 'R\$ 0,00',
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _SummaryCard(
                                      label: 'Startups',
                                      value: '0',
                                    ),
                                  ),
                                ],
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

                                final type = data['type'] ?? data['tipo'] ?? '';

                                final title = data['title'] ??
                                    data['descricao'] ??
                                    (type == 'aporte_simulado' ? 'Adição de saldo' : 'Movimentação');

                                final description = data['description'] ??
                                    (type == 'aporte_simulado'
                                        ? 'Crédito interno'
                                        : data['startupName'] ?? 'Movimentação');

                                final rawAmount = data['amount'] ?? data['valorTotal'] ?? 0;
                                final amount = rawAmount is num ? rawAmount.toDouble() : 0.0;

                                final createdAt = data['createdAt'] as Timestamp?;

                                final isCredit = type == 'aporte_simulado' ||
                                    type == 'credito' ||
                                    amount > 0;

                                return _TransactionCard(
                                  title: title.toString().replaceAll('simulado', '').trim(),
                                  subtitle: description.toString().replaceAll('simulado', '').trim(),
                                  value: isCredit
                                      ? _formatCurrency(amount)
                                      : _formatNegativeCurrency(amount),
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
  const _QuickAmountButton({
    required this.label,
    required this.onTap,
  });

  /// Constrói um botão com contorno e estilo primário
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
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
            child: Icon(
              _icon,
              color: AppColors.primary,
            ),
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