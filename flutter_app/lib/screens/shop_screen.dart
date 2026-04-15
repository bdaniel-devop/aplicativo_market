import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'product_details_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercado', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Pesquisar colheitas...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.secondaryText),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final List<Map<String, String>> categories = [
      {'id': 'all', 'name': 'Todos', 'icon': '📂'},
      {'id': '1', 'name': 'Cereais', 'icon': '🌾'},
      {'id': '2', 'name': 'Leguminosas', 'icon': '🫘'},
      {'id': '3', 'name': 'Hortícolas', 'icon': '🥬'},
      {'id': '4', 'name': 'Frutas', 'icon': '🍎'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = (_selectedCategory == cat['id']) || (_selectedCategory == null && cat['id'] == 'all');
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text('${cat['icon']} ${cat['name']}'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = cat['id'] == 'all' ? null : cat['id'];
                });
              },
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.darkText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final marketProvider = Provider.of<MarketProvider>(context);
    
    // In a real app, products would come from the provider.
    // For now, let's create a small mock list to demonstrate filtering.
    final mockProducts = [
      {'id': '1', 'name': 'Milho Branco', 'cat': '1', 'price': '1.550 MZN'},
      {'id': '2', 'name': 'Feijão Catarino', 'cat': '2', 'price': '2.100 MZN'},
      {'id': '3', 'name': 'Alface Fresca', 'cat': '3', 'price': '450 MZN'},
      {'id': '4', 'name': 'Maçã Nacional', 'cat': '4', 'price': '800 MZN'},
      {'id': '5', 'name': 'Arroz de Chokwe', 'cat': '1', 'price': '1.800 MZN'},
      {'id': '6', 'name': 'Tomate Cereja', 'cat': '3', 'price': '600 MZN'},
    ];

    final filteredProducts = mockProducts.where((p) {
      final matchesCategory = _selectedCategory == null || p['cat'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || p['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text('Nenhum produto encontrado nesta categoria.', style: TextStyle(color: AppTheme.secondaryText)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        final productId = product['id']!;
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(productId: productId),
              ),
            );
          },
          child: _buildShopProductCard(context, productId, product['name']!, product['price']!),
        );
      },
    );
  }

  Widget _buildShopProductCard(BuildContext context, String productId, String name, String price) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1551754655-cd27e38d2076?auto=format&fit=crop&q=80&w=400'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Grão Seco', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text('Machamba do Mateus', style: TextStyle(fontSize: 10, color: AppTheme.secondaryText)),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Text('/ Saco 50kg', style: TextStyle(fontSize: 10, color: AppTheme.secondaryText)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<MarketProvider>(context, listen: false).addToCart(productId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Adicionado ao carrinho!'),
                          duration: Duration(seconds: 1),
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Adicionar', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
