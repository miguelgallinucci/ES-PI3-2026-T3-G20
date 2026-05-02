import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/pages/login_page.dart';

class MesclaInvestApp extends StatelessWidget {
  const MesclaInvestApp({super.key});

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
      home: const LoginPage(),
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