import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import '../../catalog/pages/catalog_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),

                    SizedBox(
                      height: 300,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.25,
                              child: CustomPaint(
                                painter: PremiumChartPainter(),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 130,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF071A2B)
                                        .withValues(alpha: 0.92),
                                    const Color(0xFF071A2B),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: 85,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    width: 92,
                                    height: 92,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primaryLight,
                                          AppColors.primary,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.14,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.25,
                                          ),
                                          blurRadius: 28,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'MI',
                                        style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const Positioned(
                            left: 0,
                            right: 0,
                            bottom: 18,
                            child: Text(
                              'Bem-vindo ao seu\nfuturo',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.00,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Acompanhe startups, tokens e investimentos em um ambiente moderno e interativo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Acesse sua conta para continuar.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const AppInput(
                            label: 'Email',
                            hint: 'seu@email.com',
                          ),
                          const SizedBox(height: 18),

                          const AppInput(
                            label: 'Senha',
                            hint: '••••••••',
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const ForgotPasswordPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Esqueceu a senha?',
                                  style: TextStyle(
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          AppButton(
                            text: 'Entrar',
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CatalogPage(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 18),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Não tem conta? ',
                                style: TextStyle(color: Colors.white),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Cadastre-se',
                                  style: TextStyle(
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

class PremiumChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    for (int i = 1; i <= 5; i++) {
      final x = size.width * (i / 6);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    final blueLinePoints = [
      Offset(size.width * 0.00, size.height * 0.62),
      Offset(size.width * 0.18, size.height * 0.38),
      Offset(size.width * 0.34, size.height * 0.56),
      Offset(size.width * 0.52, size.height * 0.30),
      Offset(size.width * 0.78, size.height * 0.46),
      Offset(size.width * 0.96, size.height * 0.12),
    ];

    final pinkLinePoints = [
      Offset(size.width * 0.00, size.height * 0.72),
      Offset(size.width * 0.16, size.height * 0.82),
      Offset(size.width * 0.30, size.height * 0.50),
      Offset(size.width * 0.48, size.height * 0.72),
      Offset(size.width * 0.66, size.height * 0.28),
      Offset(size.width * 0.94, size.height * 0.52),
    ];

    Path buildLinePath(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      return path;
    }

    final bluePath = buildLinePath(blueLinePoints);
    final pinkPath = buildLinePath(pinkLinePoints);

    final blueGlowPaint = Paint()
      ..color = const Color(0xFF3BA7FF).withValues(alpha: 0.16)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final pinkGlowPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.14)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final blueLinePaint = Paint()
      ..color = const Color(0xFF3BA7FF).withValues(alpha: 0.95)
      ..strokeWidth = 4.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pinkLinePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.primaryLight,
          AppColors.primary,
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..strokeWidth = 4.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(bluePath, blueGlowPaint);
    canvas.drawPath(pinkPath, pinkGlowPaint);

    canvas.drawPath(bluePath, blueLinePaint);
    canvas.drawPath(pinkPath, pinkLinePaint);

    final blueDotPaint = Paint()
      ..color = const Color(0xFF3BA7FF)
      ..style = PaintingStyle.fill;

    final pinkDotPaint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.fill;

    for (final point in blueLinePoints) {
      canvas.drawCircle(
        point,
        7,
        Paint()
          ..color = const Color(0xFF3BA7FF).withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(point, 4.2, blueDotPaint);
      canvas.drawCircle(
        point,
        1.6,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }

    for (final point in pinkLinePoints) {
      canvas.drawCircle(
        point,
        7,
        Paint()
          ..color = AppColors.primaryLight.withValues(alpha: 0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(point, 4.2, pinkDotPaint);
      canvas.drawCircle(
        point,
        1.6,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }

    final fadePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF071A2B).withValues(alpha: 0.92),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          size.height * 0.55,
          size.width,
          size.height * 0.45,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height * 0.55,
        size.width,
        size.height * 0.45,
      ),
      fadePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}