// aba perfil (minha carteira, dashboard e etc)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/pages/login_page.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../portfolio/pages/portfolio_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  String _getUserName(Map<String, dynamic>? userData, User? firebaseUser) {
    final firestoreName = userData?['fullName'] ??
        userData?['nomeCompleto'] ??
        userData?['nome'] ??
        userData?['name'] ??
        userData?['displayName'] ??
        userData?['nome_completo'];

    if (firestoreName != null && firestoreName.toString().trim().isNotEmpty) {
      return firestoreName.toString();
    }

    if (firebaseUser?.displayName != null &&
        firebaseUser!.displayName!.trim().isNotEmpty) {
      return firebaseUser.displayName!;
    }

    return 'Usuário';
  }

  String _getUserEmail(Map<String, dynamic>? userData, User? firebaseUser) {
    final firestoreEmail = userData?['email'];

    if (firestoreEmail != null && firestoreEmail.toString().trim().isNotEmpty) {
      return firestoreEmail.toString();
    }

    if (firebaseUser?.email != null && firebaseUser!.email!.trim().isNotEmpty) {
      return firebaseUser.email!;
    }

    return 'E-mail não informado';
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _watchCurrentUserData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return null;
    }

    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userStream = _watchCurrentUserData();

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
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: userStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 120),
                        child: Center(
                          child: Text(
                            'Erro ao carregar dados do perfil.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    final userData = snapshot.data?.data();

                    final userName = _getUserName(userData, firebaseUser);
                    final userEmail = _getUserEmail(userData, firebaseUser);

                    return Column(
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
                        Center(
                          child: Text(
                            userName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            userEmail,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _ActionCard(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'Minha carteira',
                          subtitle:
                          'Veja seus investimentos e sua carteira atual.',
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
                          subtitle:
                          'Acompanhe desempenho, métricas e valorização.',
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
                          subtitle:
                          'Configurações de acesso e proteção da conta.',
                          onTap: () {},
                        ),
                        _ActionCard(
                          icon: Icons.logout_rounded,
                          title: 'Sair da conta',
                          subtitle: 'Encerrar sessão no aplicativo.',
                          onTap: () => _logout(context),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
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