import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../data/geography.dart';
import '../services/pdf_service.dart';
import '../models/app_models.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _paymentMethod;
  String? _province;
  String? _district;
  final _addressController = TextEditingController();
  bool _isSubmitting = false;

  static const _paymentMethods = [
    {'id': 'mpesa', 'label': 'M-Pesa'},
    {'id': 'emola', 'label': 'e-Mola'},
    {'id': 'mkesh', 'label': 'm-Kesh'},
    {'id': 'transferencia', 'label': 'Transferência'},
  ];

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context);
    final cartItems = market.cartItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
      body: cartItems.isEmpty ? _buildEmptyCart(navProvider) : _buildCartContent(context, market, cartItems),
      bottomNavigationBar: cartItems.isEmpty ? null : _buildCheckoutBar(context, market),
    );
  }

  Widget _buildEmptyCart(NavigationProvider navProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text('O seu carrinho está vazio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          const Text('Adicione produtos para começar as suas compras.', style: TextStyle(color: AppTheme.secondaryText)),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () => navProvider.goToMarket(), child: const Text('Explorar Mercado')),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, MarketProvider market, List<CartItem> cartItems) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...cartItems.map((item) => _buildCartTile(context, market, item)),
        const SizedBox(height: 16),
        const Text('Dados de Entrega', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: mozGeography.containsKey(_province) ? _province : null,
          decoration: _fieldDecoration('Província'),
          items: mozGeography.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (val) => setState(() {
            _province = val;
            _district = null;
          }),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: (mozGeography[_province] ?? []).contains(_district) ? _district : null,
          decoration: _fieldDecoration('Distrito'),
          items: (mozGeography[_province] ?? []).map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
          onChanged: (val) => setState(() => _district = val),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _addressController,
          decoration: _fieldDecoration('Morada / ponto de referência'),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
    );
  }

  Widget _buildCartTile(BuildContext context, MarketProvider market, CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: item.product.images.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.product.images.first, fit: BoxFit.cover))
                  : const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${item.product.price.toStringAsFixed(2)} MZN / ${item.product.unit}', style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(onPressed: () => market.removeFromCart(item.product.id), icon: const Icon(Icons.remove_circle_outline, size: 20)),
                Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => market.addToCart(item.product), icon: const Icon(Icons.add_circle_outline, size: 20, color: AppTheme.primaryGreen)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, MarketProvider market) {
    final subtotal = market.cartSubtotal;
    final commission = subtotal * 0.05;
    final total = subtotal + commission;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Subtotal', style: TextStyle(color: AppTheme.secondaryText)),
            Text('${subtotal.toStringAsFixed(2)} MZN', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Comissão (5%)', style: TextStyle(color: AppTheme.secondaryText)),
            Text('${commission.toStringAsFixed(2)} MZN', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: Text('Método de Pagamento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _paymentMethods.map((m) => _buildPaymentOption(m['id']!, m['label']!)).toList(),
          ),
          if (_paymentMethod != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Faça o pagamento de ${total.toStringAsFixed(2)} MZN via ${_paymentMethods.firstWhere((m) => m['id'] == _paymentMethod)['label']} e confirme abaixo. A encomenda ficará pendente até a produção verificar o pagamento.',
                style: const TextStyle(fontSize: 11, color: AppTheme.secondaryText),
              ),
            ),
          const Divider(height: 32),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
            Text('${total.toStringAsFixed(2)} MZN', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (_paymentMethod == null || _isSubmitting) ? null : () => _submitOrder(context, market),
              child: _isSubmitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirmo que paguei — Finalizar Encomenda'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String id, String label) {
    final isSelected = _paymentMethod == id;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.08) : Colors.grey[50],
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primaryGreen : AppTheme.darkText)),
      ),
    );
  }

  Future<void> _submitOrder(BuildContext context, MarketProvider market) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicie sessão para finalizar a encomenda.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final order = await orderProvider.createOrder(
        buyerId: authProvider.user!.id,
        buyerName: authProvider.user!.fullName,
        buyerPhone: authProvider.user!.phone,
        items: market.cartItems,
        paymentMethod: _paymentMethod!,
        province: _province,
        district: _district,
      );
      market.clearCart();
      await notificationsProvider.notify('Encomenda criada', 'A sua encomenda #${order.id.substring(0, 8)} está pendente de confirmação de pagamento.');
      if (context.mounted) _showSuccessDialog(context, order);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível criar a encomenda. Tente novamente.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Encomenda confirmada!'),
        content: Text('A sua encomenda #${order.id.substring(0, 8)} foi registada e está pendente de confirmação de pagamento.'),
        actions: [
          TextButton(
            onPressed: () => PdfService.shareOrderInvoice(order),
            child: const Text('Descarregar factura'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Concluído'),
          ),
        ],
      ),
    );
  }
}
