import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  double _totalPrice = 0.0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(ApiConstants.cartEndpoint);

      if (!mounted) return;

      if (response is Map) {
        if (response.containsKey('items')) {
          final itemsList = response['items'] as List;
          setState(() {
            _cartItems = itemsList
                .map((item) => CartItem.fromJson(item))
                .toList();
            _totalPrice = (response['subtotal'] as num?)?.toDouble() ?? 0.0;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Invalid server response';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load cart';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error connecting to server';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) return;

    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        ApiConstants.updateCartItemEndpoint(item.id),
        {'quantity': newQuantity.toString()},
      );

      if (!mounted) return;

      if (response['success'] == true || response['status'] == true) {
        _loadCart();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppWidgets.errorSnackBar(
            response['message'] ?? 'Failed to update cart',
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppWidgets.errorSnackBar('Error updating cart'));
    }
  }

  Future<void> _removeItem(CartItem item) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        ApiConstants.removeCartItemEndpoint(item.id),
        {},
      );

      if (!mounted) return;

      if (response['success'] == true || response['status'] == true) {
        _loadCart();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppWidgets.successSnackBar('Item removed from cart'));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppWidgets.errorSnackBar(
            response['message'] ?? 'Failed to remove item',
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppWidgets.errorSnackBar('Error removing item'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart', style: AppTextStyles.appBarTitle),
      ),
      body: _isLoading
          ? AppWidgets.loadingIndicator(message: 'Loading cart...')
          : _error != null
          ? AppWidgets.errorState(message: _error!, onRetry: _loadCart)
          : _cartItems.isEmpty
          ? AppWidgets.emptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add some products to get started',
              action: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Start Shopping'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return _buildCartItem(item, index);
                    },
                  ),
                ),
                _buildSummarySection(),
              ],
            ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.dangerRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: AppColors.ultraLight),
      ),
      onDismissed: (_) {
        setState(() {
          _cartItems.removeAt(index);
        });
        _removeItem(item);
      },
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Item'),
            content: const Text('Are you sure you want to remove this item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accentGray,
              borderRadius: BorderRadius.circular(8),
              image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.imageUrl == null || item.imageUrl!.isEmpty
                ? const Icon(
                    Icons.image_not_supported,
                    color: AppColors.lightGray,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTextStyles.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(item.formattedPrice, style: AppTextStyles.bodySecondary),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.accentGray),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () =>
                                _updateQuantity(item, item.quantity - 1),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: AppColors.lightGray,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${item.quantity}',
                              style: AppTextStyles.bodyPrimary.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () =>
                                _updateQuantity(item, item.quantity + 1),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.lightGray,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.formattedSubtotal,
                      style: AppTextStyles.productPrice,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBlack,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlack.withValues(alpha: 0.3),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.headingMedium),
              Text(
                '\$${_totalPrice.toStringAsFixed(2)}',
                style: AppTextStyles.productPrice.copyWith(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckoutScreen(),
                  ),
                );
              },
              child: const Text(
                'Checkout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
