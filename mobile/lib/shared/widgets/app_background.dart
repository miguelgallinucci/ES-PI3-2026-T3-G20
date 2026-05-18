import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget global que define o fundo padrão com gradiente do aplicativo MesclaInvest.
/// Centraliza a identidade visual e evita repetição de código de gradiente nas páginas.
class AppBackground extends StatelessWidget {
  /// O conteúdo que será exibido sobre o fundo.
  final Widget child;

  /// Padding opcional para o conteúdo interno.
  final EdgeInsetsGeometry? padding;

  const AppBackground({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            Color(0xFF091F33), // Tom intermediário para profundidade
            AppColors.card,
          ],
        ),
      ),
      child: child,
    );
  }
}
