// Widget responsável por exibir o seletor de período do dashboard.
//
// Isola as opções de visualização temporal, mantendo a DashboardPage
// responsável apenas pelo estado do período selecionado.
import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../../../core/theme/app_colors.dart';

class DashboardPeriodSelector extends StatelessWidget {
  final DashboardPeriod selectedPeriod;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  const DashboardPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: const [
          _DashboardPeriodButton(label: 'Dia', period: DashboardPeriod.day),
          _DashboardPeriodButton(label: 'Semana', period: DashboardPeriod.week),
          _DashboardPeriodButton(label: 'Mes', period: DashboardPeriod.month),
          _DashboardPeriodButton(label: '6M', period: DashboardPeriod.sixMonths),
          _DashboardPeriodButton(label: 'Ano', period: DashboardPeriod.year),
        ].map((button) {
          return Expanded(
            child: _DashboardPeriodButtonHost(
              button: button,
              selectedPeriod: selectedPeriod,
              onPeriodChanged: onPeriodChanged,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DashboardPeriodButtonHost extends StatelessWidget {
  final _DashboardPeriodButton button;
  final DashboardPeriod selectedPeriod;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  const _DashboardPeriodButtonHost({
    required this.button,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedPeriod == button.period;

    return GestureDetector(
      onTap: () => onPeriodChanged(button.period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.55)
                : Colors.transparent,
          ),
        ),
        child: Text(
          button.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DashboardPeriodButton {
  final String label;
  final DashboardPeriod period;

  const _DashboardPeriodButton({
    required this.label,
    required this.period,
  });
}
