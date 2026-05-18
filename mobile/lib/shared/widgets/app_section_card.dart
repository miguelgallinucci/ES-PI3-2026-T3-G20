// Widget global usado para exibir seções de conteúdo em formato de card.
//
// Centraliza o padrão visual de blocos como “Sobre”, “Documentos”,
// “Perguntas” e outras áreas informativas do aplicativo.
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppSectionCard extends StatelessWidget {
  /// Título principal da seção.
  final String title;

  /// Conteúdo que será exibido dentro do card.
  final Widget child;

  /// Subtítulo opcional para detalhamento da seção.
  final String? subtitle;

  /// Ícone opcional que pode ser exibido ao lado do título.
  final IconData? icon;

  /// Padding interno customizado para o card.
  final EdgeInsetsGeometry? padding;

  const AppSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.primaryLight,
                  size: 22,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
