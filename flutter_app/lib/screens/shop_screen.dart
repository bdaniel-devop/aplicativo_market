import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/app_models.dart';
import 'product_details_screen.dart';

class ShopScreen extends StatefulWidget {
  final String? initialCategoryId;

  const ShopScreen({super.key, this.initialCategoryId});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategoryId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final market = Provider.of<MarketProvider>(context, listen: false);
      if (market.products.isEmpty) market.fetchMarketData();
    });
  }

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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<MarketProvider>(
        builder: (context, market, _) {
          return Column(
            children: [
              _buildCategoryFilter(market),
              Expanded(child: _buildProductGrid(market)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(MarketProvider market) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildChip('all', '📂', 'Todos'),
          ...market.categories.map((c) => _buildChip(c.id, c.icon, lang.t(c.name))),
        ],
      ),
    );
  }

  Widget _buildChip(String id, String icon, String name) {
    final isSelected = (_selectedCategory == id) || (_selectedCategory == null && id == 'all');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text('$icon $name'),
        selected: isSelected,
        onSelected: (selected) => setState(() => _selectedCategory = id == 'all' ? null : id),
        selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
        labelStyle: TextStyle(color: isSelected ? AppTheme.primaryGreen : AppTheme.darkText, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor)),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildProductGrid(MarketProvider market) {
    if (market.isLoading) return const Center(child: CircularProgressIndicator());

    final filteredProducts = market.products.where((p) {
      final matchesCategory = _selectedCategory == null || p.categoryId == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    if (filteredProducts.isEmpty) {
      return const Center(child: Text('Nenhum produto encontrado nesta categoria.', style: TextStyle(color: AppTheme.secondaryText)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.68),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(productId: product.id))),
          child: _buildShopProductCard(context, product),
        );
      },
    );
  }

  Widget _buildShopProductCard(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    image: product.images.isNotEmpty ? DecorationImage(image: NetworkImage(product.images.first), fit: BoxFit.cover) : null,
                  ),
                  child: product.images.isEmpty ? const Icon(Icons.image_outlined, color: AppTheme.secondaryText) : null,
                ),
                if (product.isDried)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
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
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(product.producerName ?? '', style: const TextStyle(fontSize: 10, color: AppTheme.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('${product.price.toStringAsFixed(2)} MZN', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('/ ${product.unit}', style: const TextStyle(fontSize: 10, color: AppTheme.secondaryText)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<MarketProvider>(context, listen: false).addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Adicionado ao carrinho!'), duration: Duration(seconds: 1), backgroundColor: AppTheme.primaryGreen),
                      );
                    },
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
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
