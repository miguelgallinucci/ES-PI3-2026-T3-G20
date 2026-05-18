// Widget responsável por exibir a busca e os filtros do catálogo.
//
// Isola a interface de pesquisa, setor e estágio, mantendo a CatalogPage
// responsável apenas pela lógica de filtro e orquestração dos dados.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CatalogFilterSection extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedSector;
  final String selectedStage;
  final List<String> sectors;
  final List<String> stages;
  final ValueChanged<String> onSectorChanged;
  final ValueChanged<String> onStageChanged;
  final ValueChanged<String>? onSearchChanged;

  const CatalogFilterSection({
    super.key,
    required this.searchController,
    required this.selectedSector,
    required this.selectedStage,
    required this.sectors,
    required this.stages,
    required this.onSectorChanged,
    required this.onStageChanged,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar startup',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.03),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FilterChipBox(
                  text: selectedSector,
                  options: sectors,
                  onSelected: onSectorChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterChipBox(
                  text: selectedStage,
                  options: stages,
                  onSelected: onStageChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChipBox extends StatelessWidget {
  final String text;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _FilterChipBox({
    required this.text,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color(0xFF102235),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      onSelected: onSelected,
      itemBuilder: (context) {
        return options.map((option) {
          final bool isSelected = option == text;

          return PopupMenuItem<String>(
            value: option,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? AppColors.primaryLight : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.primaryLight,
                    size: 18,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: text.startsWith('Todos')
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.65),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: text.startsWith('Todos')
                      ? Colors.white
                      : AppColors.primaryLight,
                  fontSize: 14,
                  fontWeight: text.startsWith('Todos')
                      ? FontWeight.w500
                      : FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
