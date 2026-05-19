import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget global para cabeçalhos de página padronizados.
/// Centraliza o estilo de títulos, subtítulos e ações de navegação (voltar/trailing).
class PageHeader extends StatelessWidget {
  /// O título principal da página.
  final String title;

  /// Subtítulo opcional para fornecer mais contexto à página.
  final String? subtitle;

  /// Callback opcional para o botão de voltar. Se nulo, o botão não é exibido.
  final VoidCallback? onBack;

  /// Widget opcional para ser exibido à direita do título (ex: ícone de perfil ou configurações).
  final Widget? trailing;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onBack != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: onBack != null ? 8.0 : 0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: trailing!,
              ),
          ],
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
