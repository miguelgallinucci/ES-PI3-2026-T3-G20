import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/pages/login_page.dart';

class MesclaInvestApp extends StatelessWidget {
  const MesclaInvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MesclaInvest',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}