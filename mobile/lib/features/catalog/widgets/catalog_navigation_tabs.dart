// Widget responsável por alternar visualmente entre catálogo e balcão.
//
// Isola as abas principais da CatalogPage, mantendo a página responsável
// apenas por controlar qual conteúdo será exibido.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CatalogNavigationTabs extends StatelessWidget {
  final bool showMarket;
  final ValueChanged<bool> onChanged;

  const CatalogNavigationTabs({
    super.key,
    required this.showMarket,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavigationOption(
              icon: Icons.rocket_launch_rounded,
              text: 'Startups',
              selected: !showMarket,
              onTap: () => onChanged(false),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _NavigationOption(
              icon: Icons.swap_horiz_rounded,
              text: 'Balcão',
              selected: showMarket,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationOption({
    required this.icon,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        boxShadow: selected
            ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(21),
          child: Ink(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.22)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.75)
                    : Colors.transparent,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.32)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryLight.withValues(alpha: 0.58)
                                : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: selected
                              ? AppColors.primaryLight
                              : AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          text,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 14.5,
                            fontWeight: selected
                                ? FontWeight.w900
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 7,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
