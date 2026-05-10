import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Mantido para o catch de FirebaseFunctionsException

import '../../../core/theme/app_colors.dart';
import '../../catalog/pages/catalog_page.dart';
import '../../wallet/pages/wallet_page.dart';
import '../models/startup_model.dart';
import '../services/token_purchase_service.dart';

class TokenPurchasePage extends StatefulWidget {
  final StartupModel startup;
  final String tokenPrice;
  final String availableBalance;

  const TokenPurchasePage({
    super.key,
    required this.startup,
    required this.tokenPrice,
    required this.availableBalance,
  });

  @override
  State<TokenPurchasePage> createState() => _TokenPurchasePageState();
}

class _TokenPurchasePageState extends State<TokenPurchasePage> {
  final TextEditingController quantityController = TextEditingController();
  final TokenPurchaseService _purchaseService = TokenPurchaseService();

  double _saldoDisponivel = 0;
  bool _isLoadingSaldo = true;
  bool _isConfirming = false;

  double get tokenPriceValue =>
      double.tryParse(
        widget.tokenPrice
            .replaceAll('R\$', '')
            .replaceAll(' ', '')
            .replaceAll('.', '')
            .replaceAll(',', '.'),
      ) ??
          0;

  int get quantity => int.tryParse(quantityController.text) ?? 0;

  double get totalValue => quantity * tokenPriceValue;

  bool get hasEnoughBalance => totalValue <= _saldoDisponivel;

  bool get canConfirm =>
      !_isLoadingSaldo &&
          !_isConfirming &&
          quantity > 0 &&
          tokenPriceValue > 0 &&
          hasEnoughBalance;

  @override
  void initState() {
    super.initState();
    _loadSaldoDisponivel();
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadSaldoDisponivel() async {
    try {
      final saldo = await _purchaseService.getUserBalance();

      if (!mounted) return;

      setState(() {
        _saldoDisponivel = saldo;
        _isLoadingSaldo = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saldoDisponivel = 0;
        _isLoadingSaldo = false;
      });

      _showMessage('Não foi possível carregar o saldo da carteira.');
    }
  }


  Future<void> _confirmInvestment() async {
    if (_purchaseService.currentUserId == null) {
      _showMessage('Você precisa estar logado para investir.');
      return;
    }

    if (quantity <= 0) {
      _showMessage('Informe uma quantidade válida de tokens.');
      return;
    }

    if (totalValue > _saldoDisponivel) {
      _showMessage('Saldo insuficiente para realizar esse investimento.');
      return;
    }

    setState(() {
      _isConfirming = true;
    });

    try {
      await _purchaseService.buyTokens(
        startupId: widget.startup.id,
        quantity: quantity,
      );

      if (!mounted) return;

      setState(() {
        _saldoDisponivel -= totalValue;
      });

      _showSuccessDialog(context);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      String message = 'Não foi possível confirmar o investimento.';
      
      if (e.message == 'saldo_insuficiente') {
        message = 'Saldo insuficiente para realizar esse investimento.';
      } else if (e.message != null && e.message!.contains('Tokens insuficientes')) {
        message = 'A startup não possui tokens suficientes para esta compra.';
      } else if (e.code == 'unauthenticated') {
        message = 'Você precisa estar logado para investir.';
      } else if (e.message != null) {
        message = e.message!;
      }

      _showMessage(message);
    } catch (error) {
      if (!mounted) return;
      _showMessage('Erro ao processar investimento: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF102235),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowInsufficientBalance =
        quantity > 0 && totalValue > _saldoDisponivel && !_isLoadingSaldo;

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
                    Text(
                      'Investir em ${widget.startup.name}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Defina a quantidade de tokens e revise os dados da operação antes de confirmar.',
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
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.startup.displaySector,
                                  style: const TextStyle(
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  label: 'Preço do token',
                                  value: widget.tokenPrice,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InfoCard(
                                  label: 'Saldo disponível',
                                  value: _isLoadingSaldo
                                      ? 'Carregando...'
                                      : _formatCurrency(_saldoDisponivel),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Quantidade de tokens',
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
                            decoration: InputDecoration(
                              hintText: 'Ex: 10',
                              hintStyle: const TextStyle(
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
                            style: const TextStyle(color: Colors.white),
                          ),
                          if (shouldShowInsufficientBalance) ...[
                            const SizedBox(height: 10),
                            const Text(
                              'Saldo insuficiente para realizar esse investimento.',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
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
                                const Text(
                                  'Resumo da operação',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _SummaryRow(
                                  label: 'Startup',
                                  value: widget.startup.name,
                                ),
                                _SummaryRow(
                                  label: 'Quantidade',
                                  value: quantity.toString(),
                                ),
                                _SummaryRow(
                                  label: 'Preço unitário',
                                  value: widget.tokenPrice,
                                ),
                                _SummaryRow(
                                  label: 'Valor total',
                                  value: _formatCurrency(totalValue),
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
                              onPressed: canConfirm ? _confirmInvestment : null,
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
                                _isConfirming
                                    ? 'Confirmando...'
                                    : 'Confirmar investimento',
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $fixed';
  }

  void _goToCatalog(BuildContext pageContext, BuildContext dialogContext) {
    Navigator.of(dialogContext).pop();

    Navigator.of(pageContext).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const CatalogPage(),
      ),
          (route) => false,
    );
  }

  void _goToWallet(BuildContext pageContext, BuildContext dialogContext) {
    Navigator.of(dialogContext).pop();

    final navigator = Navigator.of(pageContext);

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const CatalogPage(),
      ),
          (route) => false,
    );

    Future.microtask(() {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => const WalletPage(),
        ),
      );
    });
  }

  void _showSuccessDialog(BuildContext pageContext) {
    showDialog(
      context: pageContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF102235),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Investimento confirmado',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Você investiu em ${widget.startup.name} com sucesso.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => _goToWallet(pageContext, dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ver carteira'),
          ),
          ElevatedButton(
            onPressed: () => _goToCatalog(pageContext, dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Voltar ao catálogo'),
          ),
        ],
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