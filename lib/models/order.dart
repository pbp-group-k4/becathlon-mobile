class Order {
  final int id;
  final String status;
  final String deliveryStatus;
  final String deliveryStatusDisplay;
  final double totalPrice;
  final DateTime createdAt;
  final int itemCount; // For list view
  final List<OrderItem>? items; // For detail view
  final ShippingAddress? shippingAddress; // For detail view
  final List<int>? ratedProductIds; // For detail view

  Order({
    required this.id,
    required this.status,
    required this.deliveryStatus,
    required this.deliveryStatusDisplay,
    required this.totalPrice,
    required this.createdAt,
    this.itemCount = 0,
    this.items,
    this.shippingAddress,
    this.ratedProductIds,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      status: json['status'] as String,
      deliveryStatus: json['delivery_status'] as String? ?? '',
      deliveryStatusDisplay: json['delivery_status_display'] as String? ?? '',
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      itemCount: json['item_count'] as int? ?? 0,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
          : null,
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(json['shipping_address'])
          : null,
      ratedProductIds: json['rated_product_ids'] != null
          ? List<int>.from(json['rated_product_ids'])
          : null,
    );
  }
  
  String get formattedTotalPrice => '\$${totalPrice.toStringAsFixed(2)}';
  String get formattedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year}';
}

class OrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
  
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
}

class ShippingAddress {
  final String fullName;
  final String phoneNumber;
  final String address;

  ShippingAddress({
    required this.fullName,
    required this.phoneNumber,
    required this.address,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      address: json['address'] as String,
    );
  }
}
