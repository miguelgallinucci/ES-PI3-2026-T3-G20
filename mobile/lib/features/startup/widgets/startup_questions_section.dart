// Widget responsável por exibir e enviar perguntas públicas sobre uma startup.
//
// Isola a área de comunidade da StartupDetailPage, mantendo a lógica principal
// de envio e leitura controlada pela página.
import 'package:flutter/material.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../core/theme/app_colors.dart';
import '../pages/startup_detail_page.dart'; // Model reference

class StartupQuestionsSection extends StatelessWidget {
  final TextEditingController controller;
  final List<StartupQuestion> questions;
  final VoidCallback onSend;

  const StartupQuestionsSection({
    super.key,
    required this.controller,
    required this.questions,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Perguntas públicas',
      subtitle: 'Dúvidas dos usuários e respostas da startup',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  minLines: 2,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Digite uma pergunta para os empreendedores...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: onSend,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text(
                      'Enviar pergunta',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryLight,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (questions.isEmpty)
            const Text(
              'Ainda não há perguntas públicas para esta startup.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < questions.length; i++) ...[
                  _QuestionItem(item: questions[i]),
                  if (i != questions.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _QuestionItem extends StatelessWidget {
  final StartupQuestion item;

  const _QuestionItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final hasAnswer = item.answer != null && item.answer!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasAnswer
              ? AppColors.border
              : AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: AppColors.primaryLight,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasAnswer)
            Padding(
              padding: const EdgeInsets.only(left: 27),
              child: Text(
                item.answer!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 27),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Aguardando resposta da startup',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
