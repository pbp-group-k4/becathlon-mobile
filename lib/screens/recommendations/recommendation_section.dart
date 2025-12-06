import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/recommendation_service.dart';
import '../../utils/styles.dart';
import '../../widgets/product_card.dart';
import '../product_detail_screen.dart';

class RecommendationSection extends StatefulWidget {
  final String? category;
  final int? currentProductId;
  final String title;

  const RecommendationSection({
    super.key,
    this.category,
    this.currentProductId,
    this.title = "You might also like", // Default title
  });

  @override
  State<RecommendationSection> createState() => _RecommendationSectionState();
}

class _RecommendationSectionState extends State<RecommendationSection> {
  final RecommendationService _service = RecommendationService();
  List<Product> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  // Reload when widget configuration changes (e.g. category filter updates)
  @override
  void didUpdateWidget(covariant RecommendationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _loadRecommendations();
    }
  }

  Future<void> _loadRecommendations() async {
    // Reset loading state if category changed
    setState(() => _isLoading = true);

    final results = await _service.getRecommendations(
      context,
      category: widget.category,
      currentProductId: widget.currentProductId,
    );

    if (mounted) {
      setState(() {
        _recommendations = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            widget.title,
            style: AppTextStyles.headingMedium,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _recommendations.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = _recommendations[index];
              return SizedBox(
                width: 180,
                child: ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}