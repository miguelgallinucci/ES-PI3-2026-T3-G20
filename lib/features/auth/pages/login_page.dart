import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import '../../catalog/pages/catalog_page.dart';

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
  final TextEditingController _smsCodeController = TextEditingController();
  final TextEditingController _twoFactorPhoneController = TextEditingController();
  static const String _simulatedTwoFactorCode = '123456';

  // Estado de carregamento, visibilidade de senha e mensagem de erro
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    // Libera os recursos dos controladores de texto ao descartar o widget
    _emailController.dispose();
    _passwordController.dispose();
    _smsCodeController.dispose();
    _twoFactorPhoneController.dispose();
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

      await _startSimulatedTwoFactorAuthentication();
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

  //

  Future<void> _startSimulatedTwoFactorAuthentication() async {
    final phone = await _showPhoneDialog();

    if (phone == null || phone.isEmpty) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Informe um telefone para receber o código de verificação.';
      });
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Código de verificação enviado.',
        ),
      ),
    );

    final smsCode = await _showSmsCodeDialog();

    if (smsCode == null || smsCode.isEmpty) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Digite o código de verificação para continuar.';
      });
      return;
    }

    if (smsCode != _simulatedTwoFactorCode) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Código de verificação incorreto.';
      });
      return;
    }

    await _authService.markMfaEnabled();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const CatalogPage(),
      ),
    );
  }

  Future<String?> _showPhoneDialog() async {
    _twoFactorPhoneController.clear();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1D2D).withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.42),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 28,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryLight.withValues(alpha: 0.24),
                              AppColors.primary.withValues(alpha: 0.10),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primaryLight.withValues(alpha: 0.45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.phone_in_talk_outlined,
                          color: AppColors.primaryLight,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Verifique seu telefone',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Informe seu número para receber o código de verificação.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.055),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Text(
                            '🇧🇷',
                            style: TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            '+55',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _twoFactorPhoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '(11) 99999-9999',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 58,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.24),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              _twoFactorPhoneController.text.trim(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Enviar código',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.shield_outlined,
                          color: AppColors.textSecondary,
                          size: 21,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Seus dados estão protegidos com segurança de nível bancário.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _showSmsCodeDialog() async {
    _smsCodeController.clear();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1D2D).withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.42),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 28,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryLight.withValues(alpha: 0.24),
                              AppColors.primary.withValues(alpha: 0.10),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primaryLight.withValues(alpha: 0.45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primaryLight,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Código de segurança',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Digite o código recebido para concluir a autenticação em dois fatores.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _smsCodeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 7,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'Código',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.055),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.primaryLight),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 58,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.24),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, _smsCodeController.text.trim());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Verificar',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
      case 'invalid-phone-number':
        return 'O número de telefone cadastrado não é válido.';
      case 'invalid-verification-code':
        return 'O código SMS informado está incorreto.';
      case 'credential-already-in-use':
        return 'Este telefone já está vinculado a outra conta.';
      case 'provider-already-linked':
        return 'Este telefone já está vinculado à sua conta.';
      case 'quota-exceeded':
        return 'Limite de envio de SMS excedido. Tente novamente mais tarde.';
      default:
        return 'Erro ao fazer login. Verifique os dados e tente novamente.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Container com gradiente azul escuro como fundo
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
                                        'PI3',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
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
                              'Bem-vindo de volta',
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
                      'Acesse sua conta para continuar',
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