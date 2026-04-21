import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/mock_startups.dart';
import '../models/startup_model.dart';
import '../widgets/startup_card.dart';
import 'startup_details_page.dart';
import '../../profile/pages/profile_page.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF04111D),
              Color(0xFF071A2B),
              Color(0xFF0A2235),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Catálogo de Startups',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfilePage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Explore startups, acompanhe setores promissores e descubra novas oportunidades.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          TextField(
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
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: const [
                              Expanded(
                                child: _FilterChipBox(text: 'Todos os setores'),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _FilterChipBox(text: 'Todos os estágios'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    ...mockStartups.map(
                          (startup) => StartupCard(
                        name: startup.name,
                        sector: startup.sector,
                        stage: startup.stage,
                        description: startup.description,
                        capital: startup.capital,
                        tokens: startup.tokens,
                        onTap: () => _openDetails(context, startup),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, StartupModel startup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StartupDetailsPage(
          name: startup.name,
          sector: startup.sector,
          stage: startup.stage,
          description: startup.description,
          capital: startup.capital,
          tokens: startup.tokens,
        ),
      ),
    );
  }
}

class _FilterChipBox extends StatelessWidget {
  final String text;

  const _FilterChipBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}