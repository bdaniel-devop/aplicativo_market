import '../models/app_models.dart';

/// Categorias estáticas, portadas de constants.tsx do site — no Supabase
/// `products.category_id` é só um texto livre ('1'..'6'), não há tabela
/// `categories`; a lista de categorias é sempre esta, fixa no cliente.
final List<Category> staticCategories = [
  Category(id: '1', name: 'cat_cereals', icon: '🌾'),
  Category(id: '2', name: 'cat_legumes', icon: '🫘'),
  Category(id: '3', name: 'cat_veg', icon: '🥬'),
  Category(id: '4', name: 'cat_fruit', icon: '🍎'),
  Category(id: '5', name: 'cat_roots', icon: '🥔'),
  Category(id: '6', name: 'cat_inputs', icon: '🚜'),
];
