import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/styles.dart';

/// A reusable product card widget that displays product information
/// in a visually appealing card format.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      color: AppColors.secondaryBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.subtleBorder),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: const BoxDecoration(color: AppColors.accentGray),
                child: product.image.isNotEmpty
                    ? Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            AppWidgets.imagePlaceholder(),
                      )
                    : AppWidgets.imagePlaceholder(),
              ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    if (product.brand.isNotEmpty)
                      Text(
                        product.brand.toUpperCase(),
                        style: AppTextStyles.productBrand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 4),

                    // Product Name
                    Text(
                      product.name,
                      style: AppTextStyles.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Rating
                    AppWidgets.ratingRow(
                      rating: product.ratingValue,
                      ratingText: product.rating,
                    ),

                    const SizedBox(height: 8),

                    // Price and Stock Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // FIX: Wrapped in Flexible to prevent overflow
                        Flexible(
                          child: Text(
                            product.formattedPrice,
                            style: AppTextStyles.productPrice,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4), // Small spacing
                        AppWidgets.stockBadge(inStock: product.isInStock),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}