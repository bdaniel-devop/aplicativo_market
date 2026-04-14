import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.05),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 48),
                const SizedBox(height: 24),
                Text(
                  _isLogin ? 'Bem-vindo de volta' : 'Crie sua conta',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin 
                    ? 'Acesse o ecossistema AgroSuste Moçambique' 
                    : 'Faça parte da maior rede agrícola nacional',
                  style: const TextStyle(color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 48),
                
                if (!_isLogin) 
                  _buildTextField(_nameController, 'Nome Completo', Icons.person_outline),
                
                _buildTextField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                _buildTextField(_passwordController, 'Palavra-passe', Icons.lock_outline, obscureText: true),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : () async {
                      try {
                        await authProvider.login(_emailController.text, _passwordController.text);
                        if (mounted) Navigator.pop(context); // Go back after login
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao entrar: $e'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: authProvider.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isLogin ? 'Entrar no Sistema' : 'Registar Agora'),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? 'Não tem conta? Registar agora' : 'Já possui credenciais? Fazer Login',
                      style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.secondaryText, size: 20),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
          ),
        ),
      ),
    );
  }
}
