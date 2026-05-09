import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_input.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import '../../catalog/pages/catalog_page.dart';
import '../../../shared/widgets/app_background.dart';

// Desenvolvido por Alycia Santos Bond
// Tela de login do aplicativo MesclaInvest

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// Estado da página de login.
/// Gerencia os controladores de entrada, estado de carregamento e mensagens de erro.
class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  // Controladores para os campos de email e senha
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Estado de carregamento, visibilidade de senha e mensagem de erro
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    // Libera os recursos dos controladores de texto ao descartar o widget
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Realiza o login do usuário com email e senha.
  /// Valida os campos, faz autenticação via Firebase e navega para a página de catálogo.
  /// Trata erros de autenticação e exibe mensagens apropriadas.
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Preencha e-mail e senha para continuar.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CatalogPage(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(error.code);
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Não foi possível entrar. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Converte códigos de erro do Firebase em mensagens em português para o usuário.
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'O e-mail informado não é válido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
        return 'Não encontramos uma conta com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
      default:
        return 'Erro ao fazer login. Verifique os dados e tente novamente.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
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

                    // Seção superior com gráfico decorativo, logo da aplicação e título de boas-vindas
                    SizedBox(
                      height: 300,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.25,
                              child: Transform.translate(
                                offset: const Offset(0, -27),
                                child: CustomPaint(
                                  painter: PremiumChartPainter(),
                                ),
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

                    // Texto descritivo da aplicação
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

                    // Painel principal com formulário de login
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
                          // Título do formulário
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

                          // Campo de entrada para email
                          AppInput(
                            label: 'Email',
                            hint: 'seu@email.com',
                            controller: _emailController,
                          ),
                          const SizedBox(height: 18),

                          // Campo de entrada para senha com toggle de visibilidade
                          AppInput(
                            label: 'Senha',
                            hint: '••••••••',
                            obscureText: _obscurePassword,
                            controller: _passwordController,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Botão para recuperação de senha
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

                          // Exibe mensagem de erro se houver falha na autenticação
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Botão principal de login
                          AppButton(
                            text: _isLoading ? 'Entrando...' : 'Entrar',
                            onPressed: _isLoading ? () {} : _login,
                          ),

                          const SizedBox(height: 18),

                          // Link para página de cadastro
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

/// Painter personalizado que desenha um gráfico decorativo com linhas azuis e gradiente rosa.
/// Usado como elemento visual na seção superior da página de login.
class PremiumChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Desenha linhas de grade muito sutis como fundo
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;

    // Linhas horizontais da grade
    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Linhas verticais da grade
    for (int i = 1; i <= 5; i++) {
      final x = size.width * (i / 6);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Pontos da primeira linha do gráfico (azul)
    final blueLinePoints = [
      Offset(size.width * 0.00, size.height * 0.62),
      Offset(size.width * 0.18, size.height * 0.38),
      Offset(size.width * 0.34, size.height * 0.56),
      Offset(size.width * 0.52, size.height * 0.30),
      Offset(size.width * 0.78, size.height * 0.46),
      Offset(size.width * 0.96, size.height * 0.12),
    ];

    // Pontos da segunda linha do gráfico (gradiente rosa/primário)
    final pinkLinePoints = [
      Offset(size.width * 0.00, size.height * 0.72),
      Offset(size.width * 0.16, size.height * 0.82),
      Offset(size.width * 0.30, size.height * 0.50),
      Offset(size.width * 0.48, size.height * 0.72),
      Offset(size.width * 0.66, size.height * 0.28),
      Offset(size.width * 0.94, size.height * 0.52),
    ];

    // Helper para construir um caminho a partir de uma lista de pontos
    Path buildLinePath(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      return path;
    }

    // Cria os caminhos para as duas linhas do gráfico
    final bluePath = buildLinePath(blueLinePoints);
    final pinkPath = buildLinePath(pinkLinePoints);

    // Paint para o brilho/glow da linha azul
    final blueGlowPaint = Paint()
      ..color = const Color(0xFF3BA7FF).withValues(alpha: 0.16)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Paint para o brilho/glow da linha rosa
    final pinkGlowPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.14)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Paint para a linha azul sólida
    final blueLinePaint = Paint()
      ..color = const Color(0xFF3BA7FF).withValues(alpha: 0.95)
      ..strokeWidth = 4.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Paint para a linha rosa com gradiente
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