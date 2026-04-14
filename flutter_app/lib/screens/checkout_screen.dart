import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'home_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    final cart = marketProvider.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      ),
      body: cart.isEmpty ? _buildEmptyCart(context) : _buildCartList(context, marketProvider),
      bottomNavigationBar: cart.isEmpty ? null : _buildCheckoutBar(context, marketProvider),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            'Seu carrinho está vazio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 8),
          const Text('Adicione produtos para começar suas compras.', style: TextStyle(color: AppTheme.secondaryText)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Usually go back to shop
            },
            child: const Text('Explorar Mercado'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, MarketProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.cart.length,
      itemBuilder: (context, index) {
        final productId = provider.cart.keys.elementAt(index);
        final quantity = provider.cart.values.elementAt(index);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Produto #$productId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Text('1.550 MZN / un', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(onPressed: () => provider.removeFromCart(productId), icon: const Icon(Icons.remove_circle_outline, size: 20)),
                    Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => provider.addToCart(productId), icon: const Icon(Icons.add_circle_outline, size: 20, color: AppTheme.primaryGreen)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar(BuildContext context, MarketProvider provider) {
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: TextStyle(color: AppTheme.secondaryText)),
              Text('4.650 MZN', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Comissão (5%)', style: TextStyle(color: AppTheme.secondaryText)),
              Text('232.50 MZN', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 32),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
              Text('4.882.50 MZN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Finalizar Encomenda'),
            ),
          ),
        ],
      ),
    );
  }
}
