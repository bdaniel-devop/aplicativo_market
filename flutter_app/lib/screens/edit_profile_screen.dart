import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../data/geography.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _commercialPhoneController;
  late final TextEditingController _postoController;
  late final TextEditingController _localidadeController;
  String? _province;
  String? _district;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    _nameController = TextEditingController(text: user.fullName);
    _phoneController = TextEditingController(text: user.phone);
    _commercialPhoneController = TextEditingController(text: user.commercialPhone);
    _postoController = TextEditingController(text: user.posto ?? '');
    _localidadeController = TextEditingController(text: user.localidade ?? '');
    _province = user.province;
    _district = user.district;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Dados')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                child: Text(
                  _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildField(_nameController, 'Nome Completo'),
            _buildField(_phoneController, 'Telefone', keyboardType: TextInputType.phone),
            _buildField(_commercialPhoneController, 'Telefone Comercial (opcional)', keyboardType: TextInputType.phone),
            DropdownButtonFormField<String>(
              value: mozGeography.containsKey(_province) ? _province : null,
              decoration: const InputDecoration(labelText: 'Província'),
              items: mozGeography.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) => setState(() {
                _province = val;
                _district = null;
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: (mozGeography[_province] ?? []).contains(_district) ? _district : null,
              decoration: const InputDecoration(labelText: 'Distrito'),
              items: (mozGeography[_province] ?? []).map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => _district = val),
            ),
            const SizedBox(height: 12),
            _buildField(_postoController, 'Posto Administrativo (opcional)'),
            _buildField(_localidadeController, 'Localidade/Bairro (opcional)'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Guardar Alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(controller: controller, keyboardType: keyboardType, decoration: InputDecoration(labelText: label)),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).updateProfile({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'commercial_phone': _commercialPhoneController.text.trim(),
        'province': _province,
        'district': _district,
        'posto_administrativo': _postoController.text.trim().isEmpty ? null : _postoController.text.trim(),
        'localidade_bairro': _localidadeController.text.trim().isEmpty ? null : _localidadeController.text.trim(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível guardar as alterações.'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
