import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/app_logo.dart';
import '../models/app_models.dart';
import '../data/geography.dart';
import 'admin_dashboard_screen.dart';
import 'extensionist_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  int _currentStep = 0;

  final _loginIdentifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Passo 1 — dados pessoais
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Passo 2 — tipo e papel
  String _selectedEntityType = EntityType.individual;
  String _selectedRole = UserRole.buyer;
  final _entityNameController = TextEditingController();
  String? _selectedProvince;
  String? _selectedDistrict;
  final _postoController = TextEditingController();
  final _localidadeController = TextEditingController();

  final Map<String, String> _entityTypeLabels = const {
    EntityType.individual: 'Produtor Individual',
    EntityType.association: 'Associação',
    EntityType.cooperative: 'Cooperativa',
    EntityType.company: 'Empresa',
    EntityType.ngoIntl: 'ONG Internacional',
    EntityType.other: 'Outro',
  };

  final Map<String, String> _roleLabels = const {
    UserRole.buyer: 'Comprador',
    UserRole.seller: 'Produtor',
    UserRole.transporter: 'Transportador',
    UserRole.extensionist: 'Técnico Extensionista',
    UserRole.strategicPartner: 'Parceiro Estratégico',
    UserRole.other: 'Outro',
  };

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.05)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const AppLogo(size: 80),
                const SizedBox(height: 24),
                Text(
                  _isLogin ? 'Bem-vindo de volta' : 'Crie sua conta',
                  style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 28, color: AppTheme.darkText),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Acesse o ecossistema AgroSuste Moçambique'
                      : 'Faça parte da maior rede agrícola nacional',
                  style: const TextStyle(color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 48),
                if (_isLogin) _buildLoginFields(authProvider) else _buildRegisterStepper(authProvider),
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
        _buildTextField(_loginIdentifierController, 'Email ou Telefone', Icons.person_outline),
        _buildTextField(_loginPasswordController, 'Palavra-passe', Icons.lock_outline, obscureText: true),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : () => _handleLogin(authProvider),
            child: authProvider.isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Entrar no Sistema'),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (_loginIdentifierController.text.trim().isEmpty || _loginPasswordController.text.isEmpty) {
      _showError('Preencha o email/telefone e a palavra-passe.');
      return;
    }
    try {
      await authProvider.login(_loginIdentifierController.text.trim(), _loginPasswordController.text);
      if (mounted) _navigateAfterAuth(authProvider);
    } catch (e) {
      _showError('Credenciais inválidas ou servidor indisponível.');
    }
  }

  /// Encaminhamento por papel após autenticação, tal como o App.tsx do site
  /// (Admin/Parceiro → painel administrativo, Extensionista → painel próprio).
  void _navigateAfterAuth(AuthProvider authProvider) {
    final role = authProvider.user?.role;
    Navigator.pop(context);
    if (role == UserRole.admin || role == UserRole.strategicPartner) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
    } else if (role == UserRole.extensionist) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ExtensionistDashboardScreen()));
    }
  }

  Widget _buildRegisterStepper(AuthProvider authProvider) {
    return Stepper(
      physics: const NeverScrollableScrollPhysics(),
      currentStep: _currentStep,
      onStepContinue: () {
        if (_currentStep == 0 && !_validateStep0()) return;
        if (_currentStep < 2) {
          setState(() => _currentStep++);
        }
      },
      onStepCancel: () {
        if (_currentStep > 0) setState(() => _currentStep--);
      },
      steps: [
        Step(
          title: const Text('Dados Pessoais', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          content: Column(
            children: [
              _buildTextField(_nameController, 'Nome Completo', Icons.person_outline),
              _buildTextField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              _buildTextField(_phoneController, 'Telefone (ex: 841234567)', Icons.phone_outlined, keyboardType: TextInputType.phone),
              _buildTextField(_passwordController, 'Palavra-passe', Icons.lock_outline, obscureText: true),
            ],
          ),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('Tipo e Papel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          content: Column(
            children: [
              _buildDropdownField('Tipo de Entidade', _entityTypeLabels, _selectedEntityType, (val) => setState(() => _selectedEntityType = val!)),
              _buildDropdownField('Papel Operacional', _roleLabels, _selectedRole, (val) => setState(() => _selectedRole = val!)),
              if (_selectedEntityType != EntityType.individual)
                _buildTextField(_entityNameController, 'Nome da Entidade', Icons.apartment_outlined),
              _buildDropdownField(
                'Província',
                {for (var p in mozGeography.keys) p: p},
                _selectedProvince,
                (val) => setState(() {
                  _selectedProvince = val;
                  _selectedDistrict = null;
                }),
              ),
              _buildDropdownField(
                'Distrito',
                {for (var d in (mozGeography[_selectedProvince] ?? [])) d: d},
                _selectedDistrict,
                (val) => setState(() => _selectedDistrict = val),
              ),
              _buildTextField(_postoController, 'Posto Administrativo (opcional)', Icons.location_city_outlined),
              _buildTextField(_localidadeController, 'Localidade/Bairro (opcional)', Icons.pin_drop_outlined),
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
                child: Text(
                  'Ao registar-se, você concorda com os Termos de Uso e Políticas de Privacidade da AgroSuste.',
                  style: TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : () => _handleRegister(authProvider),
                  child: authProvider.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirmar Registo'),
                ),
              ),
            ],
          ),
          isActive: _currentStep >= 2,
        ),
      ],
    );
  }

  bool _validateStep0() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Preencha todos os dados pessoais.');
      return false;
    }
    return true;
  }

  Future<void> _handleRegister(AuthProvider authProvider) async {
    if (_confirmPasswordController.text != _passwordController.text) {
      _showError('As palavras-passe não coincidem.');
      return;
    }
    try {
      final loggedInDirectly = await authProvider.register({
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'role': _selectedRole,
        'entity_type': _selectedEntityType,
        'entity_name': _entityNameController.text.trim().isEmpty ? null : _entityNameController.text.trim(),
        'province': _selectedProvince,
        'district': _selectedDistrict,
        'posto': _postoController.text.trim().isEmpty ? null : _postoController.text.trim(),
        'localidade': _localidadeController.text.trim().isEmpty ? null : _localidadeController.text.trim(),
      });
      if (!mounted) return;
      if (loggedInDirectly) {
        _navigateAfterAuth(authProvider);
      } else {
        setState(() {
          _isLogin = true;
          _currentStep = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada! Confirme o seu email e depois faça login.'),
            backgroundColor: AppTheme.primaryGreen,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      _showError('Não foi possível concluir o registo. Verifique os dados e tente novamente.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildDropdownField(String label, Map<String, String> options, String? currentValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: options.containsKey(currentValue) ? currentValue : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
        ),
        items: options.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
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
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2)),
        ),
      ),
    );
  }
}
