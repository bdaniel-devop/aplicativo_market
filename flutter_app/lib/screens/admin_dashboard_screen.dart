import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

/// Subconjunto prático do AdminDashboard.tsx do site: aprovação/bloqueio de
/// utilizadores, gestão de produtos e mudança de estado de encomendas.
/// Relatórios/gráficos ficam para a Fase 2 (ver plano).
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketProvider>(context, listen: false).fetchMarketData();
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.secondaryText,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: 'Utilizadores'),
            Tab(text: 'Produtos'),
            Tab(text: 'Encomendas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _UsersTab(),
          _ProductsTab(),
          _OrdersTab(),
        ],
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketProvider>(context);
    if (market.isLoading) return const Center(child: CircularProgressIndicator());
    if (market.profiles.isEmpty) return const Center(child: Text('Sem utilizadores.', style: TextStyle(color: AppTheme.secondaryText)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: market.profiles.length,
      itemBuilder: (context, index) {
        final profile = market.profiles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(profile.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${profile.role} · ${profile.phone} · ${profile.status}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: profile.isApproved ? 'Aprovado' : 'Aprovar',
                  icon: Icon(profile.isApproved ? Icons.check_circle : Icons.check_circle_outline, color: profile.isApproved ? AppTheme.primaryGreen : AppTheme.secondaryText),
                  onPressed: profile.isApproved
                      ? null
                      : () => Provider.of<MarketProvider>(context, listen: false).approveProfile(profile.id),
                ),
                IconButton(
                  tooltip: profile.status == 'blocked' ? 'Desbloquear' : 'Bloquear',
                  icon: Icon(Icons.block, color: profile.status == 'blocked' ? Colors.red : AppTheme.secondaryText),
                  onPressed: () => Provider.of<MarketProvider>(context, listen: false)
                      .updateProfileById(profile.id, {'status': profile.status == 'blocked' ? 'active' : 'blocked'}),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketProvider>(context);
    if (market.isLoading) return const Center(child: CircularProgressIndicator());
    if (market.products.isEmpty) return const Center(child: Text('Sem produtos.', style: TextStyle(color: AppTheme.secondaryText)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: market.products.length,
      itemBuilder: (context, index) {
        final product = market.products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${product.producerName ?? "N/D"} · ${product.price.toStringAsFixed(2)} MZN'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => Provider.of<MarketProvider>(context, listen: false).deleteProduct(product.id),
            ),
          ),
        );
      },
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  static const _statuses = ['pendente', 'pago', 'entregue', 'cancelado'];

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    if (orderProvider.isLoading) return const Center(child: CircularProgressIndicator());
    if (orderProvider.orders.isEmpty) return const Center(child: Text('Sem encomendas.', style: TextStyle(color: AppTheme.secondaryText)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderProvider.orders.length,
      itemBuilder: (context, index) {
        final order = orderProvider.orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#${order.id.substring(0, 8)} · ${order.buyerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${order.total.toStringAsFixed(2)} MZN', style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
                    ],
                  ),
                ),
                DropdownButton<String>(
                  value: order.status,
                  items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) Provider.of<OrderProvider>(context, listen: false).updateOrderStatus(order.id, val);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
