// Widget responsável por exibir a introdução visual de uma startup.
//
// Centraliza nome, descrição curta, categorias e estágio/status,
// mantendo a StartupDetailPage mais limpa e focada na organização geral.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StartupIntroSection extends StatelessWidget {
  final String name;
  final String sector;
  final String stage;
  final String description;
  final VoidCallback onBack;

  const StartupIntroSection({
    super.key,
    required this.name,
    required this.sector,
    required this.stage,
    required this.description,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  _SimpleHeaderTag(
                    text: sector,
                    icon: Icons.work_rounded,
                    highlighted: true,
                  ),
                  _SimpleHeaderTag(
                    text: stage,
                    icon: Icons.show_chart_rounded,
                    highlighted: false,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _SimpleHeaderTag extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool highlighted;

  const _SimpleHeaderTag({
    required this.text,
    required this.icon,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: highlighted
              ? AppColors.primaryLight
              : AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: highlighted
                ? AppColors.primaryLight
                : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
