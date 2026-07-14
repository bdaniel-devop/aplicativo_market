import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/app_models.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RatingsProvider>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketProvider>(context);
    final product = market.productById(widget.productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Produto')),
        body: const Center(child: Text('Produto não encontrado.', style: TextStyle(color: AppTheme.secondaryText))),
      );
    }

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
              color: Colors.grey[200],
              child: product.images.isNotEmpty
                  ? Image.network(product.images.first, fit: BoxFit.cover)
                  : const Icon(Icons.image_outlined, size: 64, color: AppTheme.secondaryText),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(product.isDried ? 'Grão Seco' : 'Colheita Verificada', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(height: 12),
                  Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkText, fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  Text('Produtor: ${product.producerName ?? "N/D"}', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  _buildRatingSummary(context),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${product.price.toStringAsFixed(2)} MZN', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                      const SizedBox(width: 8),
                      Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('/ ${product.unit}', style: TextStyle(color: Colors.grey[600], fontSize: 14))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQuantitySelector(product),
                  const Divider(height: 48),
                  const Text('Descrição', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty ? 'Sem descrição disponível.' : product.description,
                    style: TextStyle(color: Colors.grey[600], height: 1.5),
                  ),
                  const Divider(height: 48),
                  _buildRatingsList(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: product.stock <= 0
                ? null
                : () {
                    for (var i = 0; i < _quantity; i++) {
                      market.addToCart(product);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produto adicionado ao carrinho!'), backgroundColor: AppTheme.primaryGreen),
                    );
                    Navigator.pop(context);
                  },
            child: Text(product.stock <= 0 ? 'Sem stock' : 'Adicionar ao Carrinho', style: const TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(Product product) {
    return Row(
      children: [
        const Text('Quantidade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const Spacer(),
        IconButton(
          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        IconButton(
          onPressed: _quantity < product.stock ? () => setState(() => _quantity++) : null,
          icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryGreen),
        ),
      ],
    );
  }

  Widget _buildRatingSummary(BuildContext context) {
    final ratingsProvider = Provider.of<RatingsProvider>(context);
    final avg = ratingsProvider.averageFor(widget.productId);
    final count = ratingsProvider.ratingsFor(widget.productId).length;
    return Row(
      children: [
        ...List.generate(5, (i) => Icon(i < avg.round() ? Icons.star : Icons.star_border, color: Colors.amber, size: 16)),
        const SizedBox(width: 6),
        Text(count == 0 ? 'Sem avaliações' : '${avg.toStringAsFixed(1)} ($count)', style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
      ],
    );
  }

  Widget _buildRatingsList(BuildContext context) {
    final ratingsProvider = Provider.of<RatingsProvider>(context);
    final ratings = ratingsProvider.ratingsFor(widget.productId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Avaliações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            TextButton(onPressed: () => _showRateDialog(context), child: const Text('Avaliar')),
          ],
        ),
        if (ratings.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Ainda não há avaliações para este produto.', style: TextStyle(color: AppTheme.secondaryText)))
        else
          ...ratings.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(r.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                        ...List.generate(5, (i) => Icon(i < r.stars ? Icons.star : Icons.star_border, color: Colors.amber, size: 12)),
                      ],
                    ),
                    if (r.comment.isNotEmpty) Text(r.comment, style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText)),
                  ],
                ),
              )),
      ],
    );
  }

  void _showRateDialog(BuildContext context) {
    final product = Provider.of<MarketProvider>(context, listen: false).productById(widget.productId);
    if (product == null) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    int stars = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Avaliar produto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                      onPressed: () => setDialogState(() => stars = i + 1),
                      icon: Icon(i < stars ? Icons.star : Icons.star_border, color: Colors.amber),
                    )),
              ),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(hintText: 'Comentário (opcional)'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<RatingsProvider>(context, listen: false).addRating(Rating(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  targetId: product.id,
                  targetName: product.name,
                  authorName: authProvider.user?.fullName ?? 'Anónimo',
                  stars: stars,
                  comment: commentController.text.trim(),
                  createdAt: DateTime.now(),
                ));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
