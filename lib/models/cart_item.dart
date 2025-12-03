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
    return CartItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
    );
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
}
