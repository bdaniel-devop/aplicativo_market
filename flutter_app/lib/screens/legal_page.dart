import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LegalSection {
  final String title;
  final String body;
  const LegalSection(this.title, this.body);
}

/// Layout partilhado pelas páginas legais (Política de Privacidade, Termos
/// de Uso), portado do componente `Section` usado em PoliticaPrivacidade.tsx
/// e TermosDeUso.tsx do site.
class LegalPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String intro;
  final List<LegalSection> sections;

  const LegalPage({super.key, required this.title, required this.icon, required this.intro, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                Expanded(child: Text(intro, style: const TextStyle(fontSize: 13, color: AppTheme.darkText, height: 1.5))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...sections.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), fontFamily: 'Poppins')),
                    const SizedBox(height: 8),
                    Text(s.body, style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText, height: 1.6)),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Center(child: Text('© 2025 AgroSuste · Todos os direitos reservados', style: TextStyle(fontSize: 11, color: AppTheme.secondaryText))),
        ],
      ),
    );
  }
}
