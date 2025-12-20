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
      // Ensure ApiConstants.orderDetailEndpoint exists in your constants file
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
        _loadOrderDetail(); // Reload full order to update UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status: ${response['delivery_status_display']}'),
            backgroundColor: AppColors.accentBlue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Ignore errors for background refresh
    }
  }

  // FEATURE: Product Rating Dialog
  Future<void> _showRatingDialog(OrderItem item) async {
    int rating = 5;
    final reviewController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.secondaryBlack,
          title: Text(
            'Rate ${item.productName}',
            style: const TextStyle(color: AppColors.ultraLight),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "How was the product?",
                style: TextStyle(color: AppColors.lightGray),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: AppColors.accentGold,
                      size: 36,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                style: const TextStyle(color: AppColors.ultraLight),
                decoration: InputDecoration(
                  hintText: 'Write a review (optional)',
                  hintStyle: const TextStyle(color: AppColors.lightGray),
                  filled: true,
                  fillColor: AppColors.primaryBlack,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.lightGray)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: AppColors.ultraLight,
              ),
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
    reviewController.dispose();
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
          const SnackBar(
            content: Text('Rating submitted successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        _loadOrderDetail(); // Reload to update "Rated" status
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to submit rating'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error submitting rating'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Order Details', style: AppTextStyles.appBarTitle),
          backgroundColor: AppColors.primaryBlack,
        ),
        backgroundColor: AppColors.primaryBlack,
        body: const Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
      );
    }

    if (_error != null || _order == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Order Details', style: AppTextStyles.appBarTitle),
          backgroundColor: AppColors.primaryBlack,
        ),
        backgroundColor: AppColors.primaryBlack,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'Order not found', style: const TextStyle(color: AppColors.ultraLight)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadOrderDetail,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlack,
        elevation: 0,
        title: Text('Order #${_order!.id}', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.ultraLight),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryBlack,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentGray),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status', style: AppTextStyles.bodySecondary),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _order!.status == 'PAID' ? AppColors.successGreen.withOpacity(0.2) : AppColors.accentGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _order!.status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _order!.status == 'PAID' ? AppColors.successGreen : AppColors.ultraLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.accentGray),
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
            const SizedBox(height: 24),

            // Shipping Address
            if (_order!.shippingAddress != null) ...[
              Text('Shipping Address', style: AppTextStyles.headingMedium),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlack,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _order!.shippingAddress!.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ultraLight),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _order!.shippingAddress!.phoneNumber,
                      style: const TextStyle(color: AppColors.lightGray),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _order!.shippingAddress!.address,
                      style: const TextStyle(color: AppColors.lightGray),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Order Items
            Text('Items', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _order!.items?.length ?? 0,
              separatorBuilder: (context, index) => const Divider(color: AppColors.accentGray),
              itemBuilder: (context, index) {
                final item = _order!.items![index];
                // Check if delivery is complete and if item hasn't been rated
                final isDelivered = _order!.deliveryStatus == 'DELIVERED';
                final hasRated = _order!.ratedProductIds?.contains(item.productId) ?? false;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Container(
                        width: 70,
                        height: 70,
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
                        child: item.imageUrl.isEmpty 
                          ? const Icon(Icons.image, color: AppColors.lightGray) 
                          : null,
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.ultraLight,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.quantity} x ${item.formattedPrice}',
                              style: const TextStyle(color: AppColors.lightGray),
                            ),
                          ],
                        ),
                      ),
                      // Price & Rating
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.formattedSubtotal,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ultraLight),
                          ),
                          const SizedBox(height: 8),
                          // Rating Button Logic
                          if (isDelivered && !hasRated)
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () => _showRatingDialog(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentGold,
                                  foregroundColor: AppColors.primaryBlack,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                child: const Text('Rate'),
                              ),
                            )
                          else if (hasRated)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.successGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, size: 12, color: AppColors.successGreen),
                                  SizedBox(width: 4),
                                  Text(
                                    'Rated',
                                    style: TextStyle(
                                      color: AppColors.successGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
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
            const Divider(color: AppColors.accentGray),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: AppTextStyles.headingMedium),
                  Text(
                    _order!.formattedTotalPrice,
                    style: AppTextStyles.productPrice.copyWith(fontSize: 22),
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