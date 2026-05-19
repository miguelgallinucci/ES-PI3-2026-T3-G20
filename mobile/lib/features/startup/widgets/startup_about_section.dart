// Widget responsável por exibir a descrição institucional de uma startup.
//
// Isola a seção "Sobre o projeto", mantendo a StartupDetailPage menor
// e mais focada na organização geral da tela.
import 'package:flutter/material.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../core/theme/app_colors.dart';

class StartupAboutSection extends StatelessWidget {
  final String aboutText;

  const StartupAboutSection({
    super.key,
    required this.aboutText,
  });

  @override
  Widget build(BuildContext context) {
    if (aboutText.trim().isEmpty) return const SizedBox.shrink();

    return AppSectionCard(
      title: 'Sobre o projeto',
      subtitle: 'Resumo da proposta da startup',
      child: Text(
        aboutText,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          height: 1.6,
        ),
      ),
    );
  }
}
