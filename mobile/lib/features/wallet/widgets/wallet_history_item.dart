// Widget responsável por exibir uma movimentação no histórico da carteira.
//
// Isola o card visual de transação, mantendo a WalletPage focada na leitura
// dos dados e na organização geral da tela.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WalletHistoryItem extends StatelessWidget {
  /// Título da transação (ex: "Adição de saldo")
  final String title;
  /// Subtítulo/tipo da transação (ex: "Crédito interno")
  final String subtitle;
  /// Valor da transação formatado em moeda
  final String value;
  /// Data da transação formatada
  final String date;
  /// Indica se a transação é de crédito ou débito
  final bool isCredit;

  const WalletHistoryItem({
    super.key,
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
