import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget global para exibir estados de erro padronizados em todo o aplicativo.
/// Oferece suporte a ícone customizado, título, mensagem e ação de repetição.
class AppErrorState extends StatelessWidget {
  /// A mensagem principal do erro que será exibida ao usuário.
  final String message;

  /// Título opcional para o erro (ex: "Ops! Algo deu errado").
  final String? title;

  /// Ícone opcional para representar o erro. Se nulo, usa Icons.error_outline.
  final IconData? icon;

  /// Callback opcional para permitir que o usuário tente carregar os dados novamente.
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Tentar novamente',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
