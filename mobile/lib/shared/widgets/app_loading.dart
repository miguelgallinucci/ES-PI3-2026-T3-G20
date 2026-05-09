import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget global para exibir estados de carregamento padronizados.
/// Centraliza o CircularProgressIndicator e permite exibir uma mensagem opcional.
class AppLoading extends StatelessWidget {
  /// Mensagem opcional para ser exibida abaixo do indicador de progresso.
  final String? message;

  const AppLoading({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
