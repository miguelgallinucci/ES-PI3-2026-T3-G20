// Widget responsável por exibir as métricas principais de uma startup.
//
// Reúne informações como capital aportado, tokens disponíveis,
// tokens emitidos e status em cards padronizados.
import 'package:flutter/material.dart';
import '../../../shared/widgets/app_metric_card.dart';

class StartupMetricsSection extends StatelessWidget {
  final String capital;
  final String tokens;
  final String availableTokens;
  final String status;

  const StartupMetricsSection({
    super.key,
    required this.capital,
    required this.tokens,
    required this.availableTokens,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppMetricCard(
                label: 'Capital aportado',
                value: capital,
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppMetricCard(
                label: 'Tokens emitidos',
                value: tokens,
                icon: Icons.generating_tokens_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppMetricCard(
                label: 'Tokens disponíveis',
                value: availableTokens,
                icon: Icons.confirmation_number_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppMetricCard(
                label: 'Status',
                value: status,
                icon: Icons.verified_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
