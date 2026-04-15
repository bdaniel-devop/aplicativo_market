import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    // Para simplificar, usamos valores fictícios, mas na prática viriam do Provider/API com o productId.
    final title = 'Milho Branco de Cuamba (Lote #$productId)';
    final price = '1.550 MZN';
    final unit = 'Saco 50kg';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalhes da Colheita'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.darkText,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1551754655-cd27e38d2076?auto=format&fit=crop&q=80&w=600'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Colheita Verificada', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkText, fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  Text('Produtor: Machamba do Mateus', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(price, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('/ $unit', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ),
                    ],
                  ),
                  const Divider(height: 48),
                  const Text('Descrição', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  Text('Milho de excelente qualidade colhido recentemente no distrito de Cuamba. Ideal para moagem e uso industrial.', style: TextStyle(color: Colors.grey[600], height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Provider.of<MarketProvider>(context, listen: false).addToCart(productId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Produto adicionado ao carrinho!'), backgroundColor: AppTheme.primaryGreen),
              );
              Navigator.pop(context);
            },
            child: const Text('Adicionar ao Carrinho', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
