import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/app_models.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final market = Provider.of<MarketProvider>(context);
    final myProducts = authProvider.user == null ? <Product>[] : market.productsByProducer(authProvider.user!.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Inventário')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(context),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: myProducts.isEmpty
          ? const Center(child: Text('Ainda não publicou nenhum produto.', style: TextStyle(color: AppTheme.secondaryText)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myProducts.length,
              itemBuilder: (context, index) => _buildProductTile(context, myProducts[index]),
            ),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage: product.images.isNotEmpty ? NetworkImage(product.images.first) : null,
          child: product.images.isEmpty ? const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryGreen) : null,
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${product.price.toStringAsFixed(2)} MZN / ${product.unit} · ${product.stock} em stock'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _showProductForm(context, product: product)),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () => _confirmDelete(context, product),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover produto'),
        content: Text('Tem a certeza que quer remover "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await Provider.of<MarketProvider>(context, listen: false).deleteProduct(product.id);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showProductForm(BuildContext context, {Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _ProductForm(product: product),
    );
  }
}

class _ProductForm extends StatefulWidget {
  final Product? product;
  const _ProductForm({this.product});

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _unitController;
  late final TextEditingController _stockController;
  String? _categoryId;
  bool _isDried = false;
  String? _imageDataUri;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _unitController = TextEditingController(text: p?.unit ?? 'kg');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    _categoryId = p?.categoryId;
    _isDried = p?.isDried ?? false;
    _imageDataUri = p != null && p.images.isNotEmpty ? p.images.first : null;
  }

  bool _isUploadingImage = false;

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product == null ? 'Novo Produto' : 'Editar Produto', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const SizedBox(height: 16),
            Center(
              child: InkWell(
                onTap: _isUploadingImage ? null : _pickImage,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: _isUploadingImage
                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                      : _imageDataUri == null
                          ? const Icon(Icons.add_a_photo_outlined, color: AppTheme.secondaryText)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _imageDataUri!.startsWith('data:')
                                  ? Image.memory(base64Decode(_imageDataUri!.split(',').last), fit: BoxFit.cover)
                                  : Image.network(_imageDataUri!, fit: BoxFit.cover),
                            ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildField(_nameController, 'Nome do Produto'),
            _buildField(_descriptionController, 'Descrição', maxLines: 3),
            Row(children: [
              Expanded(child: _buildField(_priceController, 'Preço (MZN)', keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _buildField(_unitController, 'Unidade (kg, saco...)')),
            ]),
            _buildField(_stockController, 'Stock disponível', keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              value: market.categories.any((c) => c.id == _categoryId) ? _categoryId : null,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: market.categories.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.icon} ${lang.t(c.name)}'))).toList(),
              onChanged: (val) => setState(() => _categoryId = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Produto seco (não perecível)'),
              value: _isDried,
              onChanged: (val) => setState(() => _isDried = val),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(widget.product == null ? 'Publicar Produto' : 'Guardar Alterações'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 70);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _isUploadingImage = true);
    try {
      final fileName = '${DateTime.now().microsecondsSinceEpoch}_${file.name}';
      final url = await sharedSupabaseService.uploadProductImage(bytes, fileName);
      setState(() => _imageDataUri = url);
    } catch (_) {
      // Sem acesso ao Storage: mantém a imagem como base64 embutido, tal
      // como o site também faz de fallback quando o upload falha.
      setState(() => _imageDataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}');
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _save() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final market = Provider.of<MarketProvider>(context, listen: false);
    if (_nameController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha o nome e o preço.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSaving = true);
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final images = _imageDataUri != null ? [_imageDataUri!] : <String>[];

    try {
      if (widget.product == null) {
        final product = Product(
          id: '',
          producerId: authProvider.user!.id,
          categoryId: _categoryId ?? '1',
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          unit: _unitController.text.trim(),
          stock: int.tryParse(_stockController.text.trim()) ?? 0,
          images: images,
          isDried: _isDried,
        );
        await market.createProduct(product);
      } else {
        await market.updateProduct(widget.product!.id, {
          'category_id': _categoryId ?? '1',
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': price,
          'unit': _unitController.text.trim(),
          'stock': int.tryParse(_stockController.text.trim()) ?? 0,
          'images': images,
          'is_dried': _isDried,
        });
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível guardar o produto.'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
