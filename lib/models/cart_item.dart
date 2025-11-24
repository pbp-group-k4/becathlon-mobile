import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;

  void increaseQuantity() {
    if (quantity < product.stock) {
      quantity++;
    }
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}
