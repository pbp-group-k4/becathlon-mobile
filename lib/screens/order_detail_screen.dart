import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        ApiConstants.orderDetailEndpoint(widget.orderId),
      );

      if (!mounted) return;

      if (response is Map && response['status'] == true) {
        setState(() {
          _order = Order.fromJson(response['order']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load order details';
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

  Future<void> _refreshStatus() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        ApiConstants.orderStatusEndpoint(widget.orderId),
      );

      if (!mounted) return;

      if (response['status'] == true) {
        // Reload full order to update UI
        _loadOrderDetail();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status: ${response['delivery_status_display']}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Ignore errors for background refresh
    }
  }

  Future<void> _showRatingDialog(OrderItem item) async {
    int rating = 5;
    final reviewController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Rate ${item.productName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: AppColors.accentGold,
                      size: 32,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(
                  hintText: 'Write a review (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _submitRating(
                  item.productId,
                  rating,
                  reviewController.text,
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRating(int productId, int rating, String review) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(
        ApiConstants.submitRatingEndpoint(widget.orderId),
        jsonEncode({
          'product_id': productId,
          'rating': rating,
          'review': review,
        }),
      );

      if (!mounted) return;

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppWidgets.successSnackBar('Rating submitted successfully!'),
        );
        _loadOrderDetail(); // Reload to update rated status
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppWidgets.errorSnackBar(
            response['message'] ?? 'Failed to submit rating',
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error submitting rating')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Order Details', style: AppTextStyles.appBarTitle),
        ),
        body: AppWidgets.loadingIndicator(message: 'Loading order...'),
      );
    }

    if (_error != null || _order == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Order Details', style: AppTextStyles.appBarTitle),
        ),
        body: AppWidgets.errorState(
          message: _error ?? 'Order not found',
          onRetry: _loadOrderDetail,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_order!.id}', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStatus,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status', style: AppTextStyles.bodySecondary),
                        Text(
                          _order!.status,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery', style: AppTextStyles.bodySecondary),
                        Text(
                          _order!.deliveryStatusDisplay.isNotEmpty
                              ? _order!.deliveryStatusDisplay
                              : 'Pending',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Shipping Address
            if (_order!.shippingAddress != null) ...[
              Text('Shipping Address', style: AppTextStyles.headingMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _order!.shippingAddress!.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(_order!.shippingAddress!.phoneNumber),
                      const SizedBox(height: 4),
                      Text(_order!.shippingAddress!.address),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Order Items
            Text('Items', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _order!.items?.length ?? 0,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = _order!.items![index];
                final isDelivered = _order!.deliveryStatus == 'DELIVERED';
                final hasRated =
                    _order!.ratedProductIds?.contains(item.productId) ?? false;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.accentGray,
                          borderRadius: BorderRadius.circular(8),
                          image: item.imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(item.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${item.quantity} x ${item.formattedPrice}'),
                          ],
                        ),
                      ),
                      // Price & Rating
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.formattedSubtotal,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (isDelivered && !hasRated)
                            TextButton(
                              onPressed: () => _showRatingDialog(item),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Rate'),
                            )
                          else if (hasRated)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 14,
                                    color: AppColors.successGreen,
                                  ),
                                  Text(
                                    'Rated',
                                    style: TextStyle(
                                      color: AppColors.successGreen,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: AppTextStyles.headingMedium),
                  Text(
                    _order!.formattedTotalPrice,
                    style: AppTextStyles.productPrice.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
