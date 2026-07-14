import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/app_models.dart';
import 'auth_screen.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart';
import 'inventory_screen.dart';
import 'admin_dashboard_screen.dart';
import 'extensionist_dashboard_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_use_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        Provider.of<OrderProvider>(context, listen: false).fetchOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      return _buildLoginRequired(context);
    }

    final user = authProvider.user!;
    final orderProvider = Provider.of<OrderProvider>(context);
    final activeOrders = orderProvider.ordersForBuyer(user.id).where((o) => o.status == 'pendente' || o.status == 'pago').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () => authProvider.logout(), icon: const Icon(Icons.logout, color: Colors.red)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(user),
            const SizedBox(height: 24),
            _buildStatsGrid(user, activeOrders),
            const SizedBox(height: 32),
            _buildMenuSection('Núcleo Operacional', [
              _buildMenuItem(context, Icons.person_outline, 'Meus Dados', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
              _buildMenuItem(context, Icons.shopping_bag_outlined, 'Histórico de Compras', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()))),
            ]),
            if (user.role == UserRole.seller || user.role == UserRole.admin) ...[
              const SizedBox(height: 24),
              _buildMenuSection('Gestão Profissional', [
                _buildMenuItem(context, Icons.inventory_2_outlined, 'Meu Inventário', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()))),
              ]),
            ],
            if (user.role == UserRole.admin || user.role == UserRole.strategicPartner) ...[
              const SizedBox(height: 24),
              _buildMenuSection('Administração', [
                _buildMenuItem(context, Icons.admin_panel_settings_outlined, 'Painel Administrativo', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()))),
              ]),
            ],
            if (user.role == UserRole.extensionist) ...[
              const SizedBox(height: 24),
              _buildMenuSection('Extensão Rural', [
                _buildMenuItem(context, Icons.groups_outlined, 'Painel do Extensionista', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExtensionistDashboardScreen()))),
              ]),
            ],
            const SizedBox(height: 24),
            _buildMenuSection('Legal', [
              _buildMenuItem(context, Icons.privacy_tip_outlined, 'Política de Privacidade', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()))),
              _buildMenuItem(context, Icons.description_outlined, 'Termos de Uso', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfUseScreen()))),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person_outlined, size: 64, color: AppTheme.secondaryText),
            const SizedBox(height: 24),
            const Text('Acesso Necessário', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText, fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            const Text(
              'Faça login para gerir o seu perfil, ver encomendas e aceder a ferramentas profissionais.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.secondaryText),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                child: const Text('Entrar no Sistema'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(Profile user) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primaryGreen, Color(0xFF1B5E20)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Center(
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkText, fontFamily: 'Poppins')),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(user.role.toUpperCase(), style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(user.isApproved ? Icons.verified : Icons.hourglass_empty, color: user.isApproved ? Colors.blue : Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text(user.isApproved ? 'Perfil Validado' : 'Aguarda aprovação', style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Profile user, int activeOrders) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard('Saldo Disponível', '${user.balance.toStringAsFixed(2)} MZN', Icons.account_balance_wallet_outlined),
        _buildStatCard('Encomendas Ativas', '$activeOrders', Icons.local_shipping_outlined),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 10, color: AppTheme.secondaryText)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.secondaryText, letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.darkText, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.darkText)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.borderColor),
      onTap: onTap,
    );
  }
}
