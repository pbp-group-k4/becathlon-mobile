import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import 'order_detail_screen.dart';
import 'home.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'stores/store.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(ApiConstants.orderListEndpoint);

      if (!mounted) return;

      if (response is Map && response['status'] == true) {
        final ordersList = response['orders'] as List;
        setState(() {
          _orders = ordersList.map((order) => Order.fromJson(order)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load orders';
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return AppColors.successGreen;
      case 'PENDING':
        return AppColors.warningOrange;
      case 'CANCELLED':
        return AppColors.dangerRed;
      default:
        return AppColors.lightGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: AppTextStyles.appBarTitle),
      ),
      body: _isLoading
          ? AppWidgets.loadingIndicator(message: 'Loading orders...')
          : _error != null
          ? AppWidgets.errorState(message: _error!, onRetry: _loadOrders)
          : _orders.isEmpty
          ? AppWidgets.emptyState(
              icon: Icons.receipt_long,
              title: 'No orders found',
              subtitle: 'Your orders will appear here',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailScreen(orderId: order.id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order.id}',
                                style: AppTextStyles.productName,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    order.status,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getStatusColor(order.status),
                                  ),
                                ),
                                child: Text(
                                  order.status,
                                  style: TextStyle(
                                    color: _getStatusColor(order.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            order.formattedDate,
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${order.itemCount} Items',
                                style: AppTextStyles.bodyPrimary,
                              ),
                              Text(
                                order.formattedTotalPrice,
                                style: AppTextStyles.productPrice,
                              ),
                            ],
                          ),
                          if (order.deliveryStatusDisplay.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_shipping_outlined,
                                  size: 16,
                                  color: AppColors.accentBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  order.deliveryStatusDisplay,
                                  style: const TextStyle(
                                    color: AppColors.accentBlue,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.secondaryBlack,
        selectedItemColor: AppColors.accentGold,
        unselectedItemColor: AppColors.lightGray,
        currentIndex: 3,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            tooltip: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Stores',
            tooltip: 'Store Locator',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
            tooltip: 'Shopping Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
            tooltip: 'My Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            tooltip: 'My Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StoreLocatorScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
              break;
            case 3:
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }
}