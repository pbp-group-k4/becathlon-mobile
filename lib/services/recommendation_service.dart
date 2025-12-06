import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class RecommendationService {
  /// Fetches products.
  /// 
  /// If [category] is provided, filters by that category.
  /// If [currentProductId] is provided, excludes that ID from results.
  Future<List<Product>> getRecommendations(
    BuildContext context, {
    String? category,
    int? currentProductId,
    int limit = 6,
  }) async {
    try {
      final request = context.read<CookieRequest>();
      
      // Fetch products. If category is null, this fetches from the main list.
      final url = ApiConstants.productsWithParams(
        category: category,
        limit: limit + (currentProductId != null ? 2 : 0),
      );

      final response = await request.get(url);

      if (response is List) {
        final products = Product.listFromJson(response);
        
        // Filter out the current product if an ID was provided
        if (currentProductId != null) {
          return products
              .where((p) => p.id != currentProductId)
              .take(limit)
              .toList();
        }
        
        return products.take(limit).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');
      return [];
    }
  }
}