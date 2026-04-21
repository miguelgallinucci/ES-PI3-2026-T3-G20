import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../portfolio/pages/portfolio_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Center(
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Center(
                      child: Text(
                        'Alycia Bond',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Center(
                      child: Text(
                        'alycia@email.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    _ActionCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Minha carteira',
                      subtitle: 'Veja seus investimentos e sua carteira atual.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PortfolioPage(),
                          ),
                        );
                      },
                    ),

                    _ActionCard(
                      icon: Icons.bar_chart_rounded,
                      title: 'Dashboard',
                      subtitle: 'Acompanhe desempenho, métricas e valorização.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DashboardPage(),
                          ),
                        );
                      },
                    ),

                    _ActionCard(
                      icon: Icons.security_rounded,
                      title: 'Segurança',
                      subtitle: 'Configurações de acesso e proteção da conta.',
                      onTap: () {},
                    ),

                    _ActionCard(
                      icon: Icons.logout_rounded,
                      title: 'Sair',
                      subtitle: 'Encerrar sessão no aplicativo.',
                      onTap: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}