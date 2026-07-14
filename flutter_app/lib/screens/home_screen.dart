import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/app_logo.dart';
import '../widgets/ai_agent_widget.dart';
import '../models/app_models.dart';
import 'product_details_screen.dart';
import 'shop_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final market = Provider.of<MarketProvider>(context, listen: false);
      if (market.products.isEmpty) market.fetchMarketData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => market.fetchMarketData(),
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(child: _buildHero(context)),
                SliverToBoxAdapter(child: _buildCategories(context, market)),
                SliverToBoxAdapter(
                  child: _buildSectionTitle('Colheitas em destaque', 'Produtos disponíveis na plataforma agora'),
                ),
                if (market.isLoading)
                  const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())))
                else if (market.products.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                      child: Text('Ainda não há produtos publicados.', style: TextStyle(color: AppTheme.secondaryText)),
                    ),
                  )
                else
                  _buildFeaturedProducts(context, market),
                const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
              ],
            ),
          ),
          const AiAgentButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final notifications = Provider.of<NotificationsProvider>(context);
    return SliverAppBar(
      floating: true,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const AppLogo(size: 24),
          ),
          const SizedBox(width: 12),
          const Text('AgroSuste', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              icon: const Icon(Icons.notifications_none_outlined),
            ),
            if (notifications.unreadCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.05)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(20)),
            child: const Text(
              'Potencial agrícola moçambicano para o mundo',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Conectando o Campo Aos\nMercados Globais',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2, color: AppTheme.darkText, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Conectamos produtores moçambicanos a mercados nacionais e internacionais através de uma plataforma segura e moderna.',
            style: TextStyle(fontSize: 14, color: AppTheme.secondaryText, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
            child: const Text('Explorar Marketplace'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, MarketProvider market) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('O que procura?', 'Explorar a diversidade da produção nacional'),
        SizedBox(
          height: 100,
          child: market.categories.isEmpty
              ? const Center(child: Text('Sem categorias', style: TextStyle(color: AppTheme.secondaryText, fontSize: 12)))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: market.categories.length,
                  itemBuilder: (context, index) {
                    final cat = market.categories[index];
                    final lang = Provider.of<LanguageProvider>(context, listen: false);
                    return InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ShopScreen(initialCategoryId: cat.id)),
                      ),
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat.icon, style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 8),
                            Text(
                              lang.t(cat.name),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkText, fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText)),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context, MarketProvider market) {
    final featured = market.products.take(6).toList();
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildProductCard(context, featured[index]),
          childCount: featured.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: product.id))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: product.images.isNotEmpty
                      ? DecorationImage(image: NetworkImage(product.images.first), fit: BoxFit.cover)
                      : null,
                ),
                child: product.images.isEmpty ? const Icon(Icons.image_outlined, color: AppTheme.secondaryText) : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${product.price.toStringAsFixed(2)} MZN / ${product.unit}', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 12),
                      const SizedBox(width: 4),
                      Text('${product.stock} em stock', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
