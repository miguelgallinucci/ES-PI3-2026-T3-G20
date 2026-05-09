import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_input.dart';

// Desenvolvido por Alycia Santos Bond
// Tela de recuperação de senha do aplicativo MesclaInvest

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

/// Estado da página de recuperação de senha.
/// Gerencia o envio do email de redefinição e as mensagens de feedback.
class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();

  // Estado de carregamento, mensagem de feedback e indicador de sucesso
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    // Libera os recursos do controlador de texto ao descartar o widget
    _emailController.dispose();
    super.dispose();
  }

  /// Envia um email de recuperação de senha para o usuário.
  /// Valida o email, envia a instrução via Firebase e exibe mensagem de sucesso ou erro.
  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _message = 'Informe seu e-mail para recuperar a senha.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
      _isSuccess = false;
    });

    try {
      await _authService.sendPasswordResetEmail(email: email);

      setState(() {
        _message = 'Enviamos as instruções de recuperação para o e-mail informado.';
        _isSuccess = true;
      });
    } on FirebaseAuthException catch (error) {
      setState(() {
        _message = _getFirebaseErrorMessage(error.code);
        _isSuccess = false;
      });
    } catch (_) {
      setState(() {
        _message = 'Não foi possível enviar o e-mail. Tente novamente.';
        _isSuccess = false;
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
      case 'user-not-found':
        return 'Não encontramos uma conta com este e-mail.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet.';
      default:
        return 'Erro ao enviar recuperação de senha. Tente novamente.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color feedbackColor = _isSuccess ? Colors.green : Colors.red;

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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // Botão de voltar para a página anterior
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Título da página de recuperação de senha
                    const Text(
                      'Recuperar senha',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Texto descritivo com instruções para recuperação
                    const Text(
                      'Informe seu email para receber as instruções de redefinição de senha.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Painel principal com formulário de recuperação
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
                              'Receba as instruções no seu email.',
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

                          // Exibe mensagem de feedback (sucesso ou erro)
                          if (_message != null) ...[
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: feedbackColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: feedbackColor.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                _message!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Botão para enviar email de recuperação
                          AppButton(
                            text: _isLoading
                                ? 'Enviando...'
                                : 'Enviar instruções',
                            onPressed: _isLoading
                                ? () {}
                                : _sendPasswordResetEmail,
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