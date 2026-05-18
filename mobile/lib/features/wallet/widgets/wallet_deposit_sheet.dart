// Widget responsável por exibir o formulário de adição de saldo fictício.
//
// Isola o BottomSheet da carteira e controla a interface de valores rápidos,
// campo de entrada e confirmação do aporte simulado.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class WalletDepositSheet extends StatefulWidget {
  const WalletDepositSheet({super.key});

  @override
  State<WalletDepositSheet> createState() => _WalletDepositSheetState();
}

class _WalletDepositSheetState extends State<WalletDepositSheet> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitTypedValue() {
    final rawValue = _amountController.text
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

  @override
  Widget build(BuildContext context) {
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
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitTypedValue(),
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
              onPressed: _submitTypedValue,
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
  }
}

/// Botão auxiliar para rápida seleção de valores de saldo.
class _QuickAmountButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _QuickAmountButton({
    required this.label,
    required this.onTap,
  });

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
