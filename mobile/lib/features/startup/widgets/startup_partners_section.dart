// Widget responsável por exibir os sócios e mentores de uma startup.
//
// Isola a apresentação da estrutura societária e dos participantes externos,
// mantendo a StartupDetailPage mais simples e fácil de manter.
import 'package:flutter/material.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../core/theme/app_colors.dart';
import '../models/startup_detail_models.dart';

class StartupPartnersSection extends StatelessWidget {
  final List<StartupSocietyMember> societyMembers;
  final List<StartupSocietyMember> mentors;

  const StartupPartnersSection({
    super.key,
    required this.societyMembers,
    required this.mentors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (societyMembers.isNotEmpty) ...[
          AppSectionCard(
            title: 'Estrutura societária',
            subtitle: 'Participação dos sócios no projeto',
            child: Column(
              children: [
                for (int i = 0; i < societyMembers.length; i++) ...[
                  _MemberRow(member: societyMembers[i]),
                  if (i != societyMembers.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        if (mentors.isNotEmpty)
          AppSectionCard(
            title: 'Mentores e conselho',
            subtitle: 'Apoio estratégico da startup',
            child: Column(
              children: [
                for (int i = 0; i < mentors.length; i++) ...[
                  _MemberRow(member: mentors[i]),
                  if (i != mentors.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  final StartupSocietyMember member;

  const _MemberRow({
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter =
        member.name.isNotEmpty ? member.name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.16),
            child: Text(
              firstLetter,
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.role,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (member.percentage != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                member.percentage!,
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
