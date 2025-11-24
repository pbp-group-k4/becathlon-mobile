class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;
  final double? rating;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['pk']?.toString() ?? json['id']?.toString() ?? '',
      name: json['fields']?['name'] ?? json['name'] ?? '',
      description: json['fields']?['description'] ?? json['description'] ?? '',
      price: (json['fields']?['price'] ?? json['price'] ?? 0).toDouble(),
      category: json['fields']?['category'] ?? json['category'] ?? '',
      imageUrl: json['fields']?['image'] ?? json['image'] ?? '',
      stock: json['fields']?['stock'] ?? json['stock'] ?? 0,
      rating: json['fields']?['rating']?.toDouble() ?? json['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image': imageUrl,
      'stock': stock,
      'rating': rating,
    };
  }

  bool get isAvailable => stock > 0;
}
