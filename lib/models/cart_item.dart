class CartItem {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;
  final String?
  imageUrl; // Optional, might not be in all responses but useful if available

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.imageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Try multiple possible field names for image URL
    // Check: image_url, image, product.image_url, product.image
    String? imageUrl;
    
    // Try top-level fields first
    if (json['image_url'] != null) {
      final url = json['image_url'];
      if (url is String && url.isNotEmpty) {
        imageUrl = url;
      }
    } else if (json['image'] != null) {
      final url = json['image'];
      if (url is String && url.isNotEmpty) {
        imageUrl = url;
      }
    }
    
    // If not found at top level, try nested product object
    if (imageUrl == null && json['product'] != null) {
      final product = json['product'] as Map<String, dynamic>?;
      if (product != null) {
        if (product['image_url'] != null) {
          final url = product['image_url'];
          if (url is String && url.isNotEmpty) {
            imageUrl = url;
          }
        } else if (product['image'] != null) {
          final url = product['image'];
          if (url is String && url.isNotEmpty) {
            imageUrl = url;
          }
        }
      }
    }
    
    return CartItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      imageUrl: imageUrl,
    );
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
}
