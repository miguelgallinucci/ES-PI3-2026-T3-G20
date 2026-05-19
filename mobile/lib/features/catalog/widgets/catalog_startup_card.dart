// Widget responsável por exibir uma startup dentro da lista do catálogo.
//
// Isola o card visual usado na CatalogPage, mantendo a página principal
// focada na busca, filtros e orquestração dos dados.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../startup/models/startup_model.dart';

class CatalogStartupCard extends StatelessWidget {
  final StartupModel startup;
  final VoidCallback onTap;

  const CatalogStartupCard({
    super.key,
    required this.startup,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCategories = startup.categories.take(2).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOPO: tags simples à esquerda e estágio no extremo direito
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: visibleCategories.isEmpty
                    ? const SizedBox.shrink()
                    : Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: visibleCategories.map((category) {
                          return _CategoryTag(text: category);
                        }).toList(),
                      ),
              ),
              const SizedBox(width: 16),
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  startup.stage,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StartupLogo(name: startup.name),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  startup.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            startup.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _StartupMetricBox(label: 'Capital', value: startup.capital),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StartupMetricBox(label: 'Tokens', value: startup.tokens),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                'Ver mais',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String text;

  const _CategoryTag({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.sell_rounded, color: AppColors.primaryLight, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.primaryLight,
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class StartupLogo extends StatelessWidget {
  final String name;

  const StartupLogo({super.key, required this.name});

  String get initials {
    final words = name
        .trim()
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .toList();

    if (words.isEmpty) return 'ST';

    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.primaryLight.withValues(alpha: 0.60),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _StartupMetricBox extends StatelessWidget {
  final String label;
  final String value;

  const _StartupMetricBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
