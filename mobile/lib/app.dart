import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/pages/login_page.dart';

class MesclaInvestApp extends StatelessWidget {
  const MesclaInvestApp({
    super.key,
    required this.firebaseInitialization,
  });

  final Future<Object?> firebaseInitialization;

  @override
  Widget build(BuildContext context) {
    //MaterialApp é como se fosse a “caixa principal” do app Flutter, define coisas globais
// ex: comportamento geral do app, titulo do app, rotas/navegacao
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MesclaInvest',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      scrollBehavior: const NoBounceScrollBehavior(),
      home: FirebaseStartupGate(
        firebaseInitialization: firebaseInitialization,
      ),
    );
  }
}

class FirebaseStartupGate extends StatelessWidget {
  const FirebaseStartupGate({
    super.key,
    required this.firebaseInitialization,
  });

  final Future<Object?> firebaseInitialization;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object?>(
      future: firebaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AppStartupScaffold(
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
            ),
          );
        }

        final error = snapshot.data;
        if (error != null) {
          return FirebaseErrorPage(error: error);
        }

        return const LoginPage();
      },
    );
  }
}

class AppStartupScaffold extends StatelessWidget {
  const AppStartupScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          child: Center(child: child),
        ),
      ),
    );
  }
}

class FirebaseErrorPage extends StatelessWidget {
  const FirebaseErrorPage({
    super.key,
    required this.error,
  });

  final Object error;

  @override
  Widget build(BuildContext context) {
    return AppStartupScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: AppColors.primaryLight,
                size: 48,
              ),
              const SizedBox(height: 20),
              const Text(
                'Nao foi possivel iniciar o Firebase',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'O app esta configurado para Android. Se voce rodar em Chrome, Windows, Linux, macOS ou iOS, configure o Firebase para essa plataforma.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              SelectableText(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoBounceScrollBehavior extends ScrollBehavior {
  const NoBounceScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
