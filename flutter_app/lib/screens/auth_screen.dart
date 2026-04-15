import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/app_logo.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  int _currentStep = 0;
  
  // Passo 1
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  
  // Passo 2
  String? _selectedEntityType;
  String? _selectedRole;
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();

  final List<String> _entityTypes = ['Agricultor Individual', 'Cooperativa', 'Comprador Empresa', 'Instituição'];
  final List<String> _operationalRoles = ['Produtor', 'Processador', 'Logística', 'Comprador Final'];

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
                const AppLogo(size: 80),
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
                
                if (_isLogin)
                  _buildLoginFields(authProvider)
                else
                  _buildRegisterStepper(authProvider),
                
                const SizedBox(height: 12),
                
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _isLogin = !_isLogin;
                      _currentStep = 0;
                    }),
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

  Widget _buildLoginFields(AuthProvider authProvider) {
    return Column(
      children: [
        _buildTextField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        _buildTextField(_passwordController, 'Palavra-passe', Icons.lock_outline, obscureText: true),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : () async {
              if (_emailController.text == 'brestondaniel') {
                // Admin logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bem-vindo, Administrador!'), backgroundColor: Colors.blue),
                );
              }
              try {
                await authProvider.login(_emailController.text, _passwordController.text);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao entrar: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: authProvider.isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Entrar no Sistema'),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterStepper(AuthProvider authProvider) {
    return Stepper(
      physics: const NeverScrollableScrollPhysics(),
      currentStep: _currentStep,
      onStepContinue: () {
        if (_currentStep < 2) {
          setState(() => _currentStep++);
        } else {
          // Final submit logic here
        }
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() => _currentStep--);
        }
      },
      steps: [
        Step(
          title: const Text('Dados Pessoais', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          content: Column(
            children: [
              _buildTextField(_nameController, 'Nome Completo', Icons.person_outline),
              _buildTextField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              _buildTextField(_passwordController, 'Palavra-passe', Icons.lock_outline, obscureText: true),
            ],
          ),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('Tipo e Papel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          content: Column(
            children: [
              _buildDropdownField('Tipo de Entidade', _entityTypes, _selectedEntityType, (val) => setState(() => _selectedEntityType = val)),
              _buildDropdownField('Papel Operacional', _operationalRoles, _selectedRole, (val) => setState(() => _selectedRole = val)),
              _buildTextField(_provinceController, 'Província', Icons.location_on_outlined),
              _buildTextField(_districtController, 'Distrito', Icons.map_outlined),
            ],
          ),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text('Finalização', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          content: Column(
            children: [
              _buildTextField(_confirmPasswordController, 'Confirmar Palavra-passe', Icons.lock_reset, obscureText: true),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Ao registar-se, você concorda com os Termos de Uso e Políticas de Privacidade da AgroSuste.', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Confirmar Registo'),
                ),
              ),
            ],
          ),
          isActive: _currentStep >= 2,
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? currentValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
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
