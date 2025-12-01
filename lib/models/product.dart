/// Product Model for Becathlon Mobile App.
///
/// Represents a product from the Django backend API.
/// Handles JSON parsing from Django's pk/fields format.
library;

class Product {
  final int id;
  final String name;
  final String description;
  final String price;
  final String category;
  final String brand;
  final String image;
  final int stock;
  final String rating;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.brand,
    required this.image,
    required this.stock,
    required this.rating,
  });
  
  /// Parse product from Django's pk/fields JSON format
  /// 
  /// Expected format:
  /// ```json
  /// {
  ///   "pk": 1,
  ///   "fields": {
  ///     "name": "Running Shoes Pro",
  ///     "description": "Professional running shoes...",
  ///     "price": "149.99",
  ///     "category": "Running",
  ///     "brand": "Nike",
  ///     "image": "https://example.com/image.jpg",
  ///     "stock": 25,
  ///     "rating": "4.50"
  ///   }
  /// }
  /// ```
  factory Product.fromJson(Map<String, dynamic> json) {
    final fields = json['fields'] as Map<String, dynamic>;
    
    return Product(
      id: json['pk'] as int,
      name: fields['name'] as String? ?? '',
      description: fields['description'] as String? ?? '',
      price: fields['price']?.toString() ?? '0.00',
      category: fields['category'] as String? ?? '',
      brand: fields['brand'] as String? ?? '',
      image: fields['image'] as String? ?? '',
      stock: fields['stock'] as int? ?? 0,
      rating: fields['rating']?.toString() ?? '0.0',
    );
  }
  
  /// Convert product to JSON format
  Map<String, dynamic> toJson() {
    return {
      'pk': id,
      'fields': {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'brand': brand,
        'image': image,
        'stock': stock,
        'rating': rating,
      },
    };
  }
  
  /// Check if product is in stock
  bool get isInStock => stock > 0;
  
  /// Get formatted price with currency symbol
  String get formattedPrice {
    final priceValue = double.tryParse(price) ?? 0.0;
    return '\$${priceValue.toStringAsFixed(2)}';
  }
  
  /// Get numeric rating value
  double get ratingValue => double.tryParse(rating) ?? 0.0;
  
  /// Parse a list of products from JSON array
  static List<Product> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
  }
  
  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category, brand: $brand)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
