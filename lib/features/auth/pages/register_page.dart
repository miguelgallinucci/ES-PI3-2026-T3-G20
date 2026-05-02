import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../catalog/pages/catalog_page.dart';
import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
// Desenvolvido por Alycia Santos Bond
// Tela de cadastro do aplicativo MesclaInvest

/// Página de cadastro do aplicativo MesclaInvest.
/// Exibe o formulário de registro e envia dados para criação de conta.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

/// Estado da página de cadastro.
/// Gerencia os controladores de entrada, validação de dados e criação de conta via Firebase.
class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();

  // Controladores para os campos do formulário de cadastro
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Estado de carregamento e mensagem de erro
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    // Libera os recursos de todos os controladores de texto ao descartar o widget
    _fullNameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Realiza o cadastro de um novo usuário.
  /// Valida todos os campos, verifica se as senhas conferem, cria a conta no Firebase
  /// e navega para a página de catálogo após sucesso.
  Future<void> _register() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final cpf = _cpfController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        cpf.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Preencha todos os campos para criar sua conta.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'As senhas não conferem.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'A senha precisa ter pelo menos 6 caracteres.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.register(
        fullName: fullName,
        email: email,
        cpf: cpf,
        phone: phone,
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
        _errorMessage = 'Não foi possível criar a conta. Tente novamente.';
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
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'O e-mail informado não é válido.';
      case 'weak-password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'O cadastro por e-mail e senha não está habilitado.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet.';
      default:
        return 'Erro ao criar conta. Verifique os dados e tente novamente.';
    }
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

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

                    // Título da página de cadastro
                    const Text(
                      'Crie sua conta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Texto descritivo da aplicação e benefícios do cadastro
                    const Text(
                      'Cadastre-se para acompanhar startups, tokens e oportunidades do ecossistema Mescla.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Bloco principal do formulário de cadastro
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
                              'Preencha seus dados para começar.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Campo para o nome completo do usuário
                          AppInput(
                            label: 'Nome completo',
                            hint: 'Seu nome completo',
                            controller: _fullNameController,
                          ),
                          const SizedBox(height: 18),

                          // Campo para o email usado no cadastro
                          AppInput(
                            label: 'Email',
                            hint: 'seu@email.com',
                            controller: _emailController,
                          ),
                          const SizedBox(height: 18),

                          // Campo para o CPF do usuário
                          AppInput(
                            label: 'CPF',
                            hint: '000.000.000-00',
                            controller: _cpfController,
                          ),
                          const SizedBox(height: 18),

                          // Campo para o telefone de contato
                          AppInput(
                            label: 'Telefone',
                            hint: '(00) 00000-0000',
                            controller: _phoneController,
                          ),
                          const SizedBox(height: 18),

                          // Campo de senha para o novo usuário
                          AppInput(
                            label: 'Senha',
                            hint: '••••••••',
                            obscureText: true,
                            controller: _passwordController,
                          ),
                          const SizedBox(height: 18),

                          // Campo para confirmar a senha digitada
                          AppInput(
                            label: 'Confirmar senha',
                            hint: '••••••••',
                            obscureText: true,
                            controller: _confirmPasswordController,
                          ),

                          // Mostra mensagem de erro quando a validação ou cadastro falham
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

                          AppButton(
                            text: _isLoading ? 'Criando conta...' : 'Criar conta',
                            onPressed: _isLoading ? () {} : _register,
                          ),

                          const SizedBox(height: 18),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Já tem conta? ',
                                style: TextStyle(color: Colors.white),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  'Entrar',
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