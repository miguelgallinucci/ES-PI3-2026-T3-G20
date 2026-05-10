// Widget responsável por exibir os documentos públicos de uma startup.
//
// Mantém a StartupDetailPage mais limpa ao isolar a seção de documentos,
// como plano de negócios, apresentação ou outros links informativos.
import 'package:flutter/material.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../core/theme/app_colors.dart';
import '../models/startup_detail_models.dart';

class StartupDocumentsSection extends StatelessWidget {
  final List<StartupDocumentItem> documents;

  const StartupDocumentsSection({
    super.key,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) return const SizedBox.shrink();

    return AppSectionCard(
      title: 'Documentos públicos',
      subtitle: 'Materiais essenciais para análise do investidor',
      child: Column(
        children: [
          for (int i = 0; i < documents.length; i++) ...[
            _DocumentRow(item: documents[i]),
            if (i != documents.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final StartupDocumentItem item;

  const _DocumentRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.icon,
              color: AppColors.primaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
