import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/app_models.dart';
import '../services/pdf_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = authProvider.user == null ? <Order>[] : orderProvider.ordersForBuyer(authProvider.user!.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Compras')),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('Ainda não fez nenhuma encomenda.', style: TextStyle(color: AppTheme.secondaryText)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) => _buildOrderCard(orders[index]),
                ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Encomenda #${order.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('${order.items.length} item(ns) · ${order.total.toStringAsFixed(2)} MZN', style: const TextStyle(color: AppTheme.secondaryText)),
            Text('${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}', style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => PdfService.shareOrderInvoice(order),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Factura'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final colors = {
      'pendente': Colors.orange,
      'pago': Colors.blue,
      'entregue': AppTheme.primaryGreen,
      'cancelado': Colors.red,
    };
    final color = colors[status] ?? AppTheme.secondaryText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
