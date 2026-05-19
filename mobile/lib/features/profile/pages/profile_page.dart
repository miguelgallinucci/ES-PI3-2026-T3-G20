// aba perfil (minha carteira, dashboard e etc)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../../auth/services/auth_service.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/pages/login_page.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../wallet/pages/wallet_page.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/page_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  bool _isUpdatingMfa = false;

  Future<void> _logout(BuildContext context) async {
    await _profileService.signOut();

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


  @override
  Widget build(BuildContext context) {
    final firebaseUser = _profileService.currentUser;
    final userStream = _profileService.watchCurrentUserProfile();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Center(
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: userStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: AppLoading(message: 'Carregando perfil...'),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: AppErrorState(
                          title: 'Ops!',
                          message: 'Erro ao carregar dados do perfil.',
                        ),
                      );
                    }

                    final userData = snapshot.data?.data();

                    final userName = _getUserName(userData, firebaseUser);
                    final userEmail = _getUserEmail(userData, firebaseUser);
                    final isMfaEnabled = userData?['mfaEnabled'] == true;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageHeader(
                          title: 'Perfil',
                          onBack: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 24),
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
                                builder: (_) => const WalletPage(),
                              ),
                            );
                          },
                        ),
                        _ActionCard(
                          icon: Icons.bar_chart_rounded,
                          title: 'Meus investimentos',
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
                        _SecurityMfaCard(
                          enabled: isMfaEnabled,
                          isLoading: _isUpdatingMfa,
                          onChanged: (value) async {
                            if (_isUpdatingMfa) return;

                            setState(() {
                              _isUpdatingMfa = true;
                            });

                            try {
                              await _authService.setMfaEnabled(value);

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF102235),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  content: Text(
                                    value
                                        ? 'Verificação em duas etapas ativada.'
                                        : 'Verificação em duas etapas desativada.',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            } catch (_) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF102235),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  content: const Text(
                                    'Não foi possível atualizar a verificação em duas etapas.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isUpdatingMfa = false;
                                });
                              }
                            }
                          },
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

class _SecurityMfaCard extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  const _SecurityMfaCard({
    required this.enabled,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: enabled
              ? AppColors.primaryLight.withValues(alpha: 0.42)
              : AppColors.border,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  enabled
                      ? Icons.verified_user_rounded
                      : Icons.security_rounded,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Segurança',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Configurações de acesso e proteção da conta.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.14),
                  ),
                  child: const Icon(
                    Icons.phonelink_lock_rounded,
                    color: AppColors.primaryLight,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verificação em duas etapas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        enabled
                            ? 'Ativada para proteger sua conta no login.'
                            : 'Ative uma camada extra de proteção no login.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                isLoading
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.primaryLight,
                        ),
                      )
                    : Switch.adaptive(
                        value: enabled,
                        onChanged: onChanged,
                        activeColor: AppColors.primaryLight,
                        activeTrackColor:
                            AppColors.primary.withValues(alpha: 0.36),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.white24,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}