import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import 'login.dart';
import 'recommendations/recommendation_section.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isAddingToCart = false;

  Future<void> _addToCart() async {
    final request = context.read<CookieRequest>();

    if (!request.loggedIn) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      if (result != true) return;
    }

    if (!mounted) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final response = await request.post(
        ApiConstants.addToCartEndpoint(widget.product.id),
        {'quantity': _quantity.toString()},
      );

      if (!mounted) return;

      if (response['success'] == true || response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppWidgets.successSnackBar('Added to cart successfully!'),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppWidgets.errorSnackBar(
            response['message'] ?? 'Failed to add to cart',
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppWidgets.errorSnackBar('An error occurred. Please try again.'),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: AppTextStyles.appBarTitle.copyWith(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            if (widget.product.image.isNotEmpty)
              Image.network(
                widget.product.image,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 300,
                  color: AppColors.accentGray,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: AppColors.lightGray,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand & Category
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.product.category,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.product.brand.toUpperCase(),
                        style: AppTextStyles.productBrand.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(widget.product.name, style: AppTextStyles.headingLarge),
                  const SizedBox(height: 8),

                  // Price & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product.formattedPrice,
                        style: AppTextStyles.productPrice.copyWith(
                          fontSize: 28,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.accentGold),
                          const SizedBox(width: 4),
                          Text(
                            widget.product.rating,
                            style: AppTextStyles.headingMedium.copyWith(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text('Description', style: AppTextStyles.headingMedium),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: AppTextStyles.bodyPrimary.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // Stock Status & Cart Controls
                  if (!widget.product.isInStock)
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.dangerRedLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.dangerRed),
                      ),
                      child: const Text(
                        'Out of Stock',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.dangerRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else ...[
                    // Quantity Selector
                    Row(
                      children: [
                        Text(
                          'Quantity:',
                          style: AppTextStyles.bodyPrimary.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.accentGray),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: AppColors.lightGray,
                                ),
                                onPressed: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                              ),
                              Text(
                                '$_quantity',
                                style: AppTextStyles.headingMedium,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: AppColors.lightGray,
                                ),
                                onPressed: _quantity < widget.product.stock
                                    ? () => setState(() => _quantity++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${widget.product.stock} available',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isAddingToCart ? null : _addToCart,
                        child: _isAddingToCart
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryBlack,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Add to Cart',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],

                  // --- Recommendations Section ---
                  // Now placed outside the else block so it shows even if out of stock
                  const SizedBox(height: 32),
                  const Divider(color: AppColors.accentGray),
                  const SizedBox(height: 24),

                  RecommendationSection(
                    category: widget.product.category,
                    currentProductId: widget.product.id,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}