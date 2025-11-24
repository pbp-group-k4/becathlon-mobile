import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  void addToCart(Product product, {int quantity = 1}) {
    // Check if product already exists in cart
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Update quantity of existing item
      if (_items[existingIndex].quantity + quantity <= product.stock) {
        _items[existingIndex].quantity += quantity;
      }
    } else {
      // Add new item to cart
      if (quantity <= product.stock) {
        _items.add(CartItem(product: product, quantity: quantity));
      }
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (newQuantity > 0 && newQuantity <= _items[index].product.stock) {
        _items[index].quantity = newQuantity;
      } else if (newQuantity <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void increaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].increaseQuantity();
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].decreaseQuantity();
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(
        id: '',
        name: '',
        description: '',
        price: 0,
        category: '',
        imageUrl: '',
        stock: 0,
      ), quantity: 0),
    );
    return item.quantity;
  }
}
