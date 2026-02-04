import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  
  /// Rechercher des aliments par nom
  Future<List<FoodItem>> searchFood(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final url = Uri.parse('$_baseUrl/search')
          .replace(queryParameters: {
        'search_terms': query,
        'page_size': '20',
        'fields': 'code,product_name,nutriments,quantity,brands,image_url',
      });
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List? ?? [];
        
        return products
            .map((p) => FoodItem.fromOpenFoodFacts(p))
            .where((item) => item.name.isNotEmpty)
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error searching food: $e');
      return [];
    }
  }
  
  /// Récupérer un produit par code-barres
  Future<FoodItem?> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse('$_baseUrl/product/$barcode');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 1 && data['product'] != null) {
          return FoodItem.fromOpenFoodFacts(data['product']);
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting product by barcode: $e');
      return null;
    }
  }
}

class FoodItem {
  final String code;
  final String name;
  final String? brand;
  final String? quantity;
  final int caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final String? imageUrl;
  
  FoodItem({
    required this.code,
    required this.name,
    this.brand,
    this.quantity,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.imageUrl,
  });
  
  factory FoodItem.fromOpenFoodFacts(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};
    
    // Extract nutriments (per 100g)
    final calories = _parseDouble(nutriments['energy-kcal_100g'] ?? 
                                  nutriments['energy-kcal'] ?? 
                                  0).toInt();
    final protein = _parseDouble(nutriments['proteins_100g'] ?? 
                                 nutriments['proteins'] ?? 
                                 0);
    final carbs = _parseDouble(nutriments['carbohydrates_100g'] ?? 
                               nutriments['carbohydrates'] ?? 
                               0);
    final fat = _parseDouble(nutriments['fat_100g'] ?? 
                            nutriments['fat'] ?? 
                            0);
    
    return FoodItem(
      code: json['code']?.toString() ?? '',
      name: json['product_name']?.toString() ?? 'Produit inconnu',
      brand: json['brands']?.toString(),
      quantity: json['quantity']?.toString(),
      caloriesPer100g: calories,
      proteinPer100g: protein,
      carbsPer100g: carbs,
      fatPer100g: fat,
      imageUrl: json['image_url']?.toString(),
    );
  }
  
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
  
  /// Calculer les nutriments pour une quantité donnée
  Map<String, double> calculateForQuantity(double grams) {
    final factor = grams / 100;
    return {
      'calories': caloriesPer100g * factor,
      'protein': proteinPer100g * factor,
      'carbs': carbsPer100g * factor,
      'fat': fatPer100g * factor,
    };
  }
  
  /// Display name avec marque
  String get displayName {
    if (brand != null && brand!.isNotEmpty) {
      return '$name ($brand)';
    }
    return name;
  }
}
