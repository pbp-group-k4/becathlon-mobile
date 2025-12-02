/// API Constants for Becathlon Mobile App.
///
/// This file contains all the base URLs and endpoint paths
/// for the Django backend API integration.
library;

class ApiConstants {
  // Development Base URL (localhost Django server)
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  // Production Base URL (commented out - deployment broken)
  // static const String baseUrl = 'https://muhammad-vegard-becathlon.pbp.cs.ui.ac.id';
  
  // Authentication Endpoints
  static const String loginEndpoint = '$baseUrl/auth/flutter/login/';
  static const String registerEndpoint = '$baseUrl/auth/flutter/register/';
  static const String logoutEndpoint = '$baseUrl/auth/flutter/logout/';
  
  // Catalog Endpoints
  static const String productsEndpoint = '$baseUrl/catalog/mobile/products/';
  static const String categoriesEndpoint = '$baseUrl/catalog/mobile/categories/';
  
  // Cart Endpoints
  static const String cartEndpoint = '$baseUrl/cart/flutter/';
  static const String cartCountEndpoint = '$baseUrl/cart/flutter/count/';
  static const String cartClearEndpoint = '$baseUrl/cart/flutter/clear/';
  
  static String addToCartEndpoint(int productId) => '$baseUrl/cart/flutter/add/$productId/';
  static String updateCartItemEndpoint(int itemId) => '$baseUrl/cart/flutter/update/$itemId/';
  static String removeCartItemEndpoint(int itemId) => '$baseUrl/cart/flutter/remove/$itemId/';
  
  // Order Endpoints
  static const String checkoutEndpoint = '$baseUrl/order/flutter/checkout/';
  static const String orderListEndpoint = '$baseUrl/order/flutter/list/';
  
  static String orderDetailEndpoint(int orderId) => '$baseUrl/order/flutter/$orderId/';
  static String orderStatusEndpoint(int orderId) => '$baseUrl/order/flutter/$orderId/status/';
  static String submitRatingEndpoint(int orderId) => '$baseUrl/order/flutter/$orderId/rate/';
  
  /// Get product detail endpoint for a specific product ID
  static String productDetailEndpoint(int productId) {
    return '$baseUrl/catalog/mobile/products/$productId/';
  }
  
  /// Build products endpoint with query parameters
  static String productsWithParams({
    String? search,
    String? category,
    bool? inStockOnly,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int? limit,
  }) {
    final queryParams = <String, String>{};
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (inStockOnly == true) {
      queryParams['in_stock_only'] = 'true';
    }
    if (minPrice != null) {
      queryParams['min_price'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice.toString();
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sort_by'] = sortBy;
    }
    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }
    
    if (queryParams.isEmpty) {
      return productsEndpoint;
    }
    
    final queryString = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '$productsEndpoint?$queryString';
  }
}

/// Sort options available for product listing
class SortOptions {
  static const String newest = 'newest';
  static const String priceLow = 'price_low';
  static const String priceHigh = 'price_high';
  static const String nameAsc = 'name_asc';
  static const String nameDesc = 'name_desc';
  
  static const Map<String, String> displayNames = {
    newest: 'Newest',
    priceLow: 'Price: Low to High',
    priceHigh: 'Price: High to Low',
    nameAsc: 'Name: A to Z',
    nameDesc: 'Name: Z to A',
  };
}
