import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import '../widgets/product_card.dart';
import 'login.dart';
import 'cart_screen.dart';
import 'order_list_screen.dart';
import 'product_detail_screen.dart';

/// Home page with product grid display
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String? _error;

  final _searchController = TextEditingController();
  String? _selectedCategory;
  String _selectedSort = SortOptions.newest;
  bool _inStockOnly = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(ApiConstants.categoriesEndpoint);

      if (!mounted) return;

      if (response is List) {
        setState(() {
          _categories = response.map((cat) => cat['name'] as String).toList();
        });
      }
    } catch (e) {
      debugPrint('Failed to load categories: $e');
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = context.read<CookieRequest>();

      final url = ApiConstants.productsWithParams(
        search: _searchController.text.trim().isNotEmpty
            ? _searchController.text.trim()
            : null,
        category: _selectedCategory,
        sortBy: _selectedSort,
        inStockOnly: _inStockOnly ? true : null,
      );

      final response = await request.get(url);

      if (!mounted) return;

      if (response is List) {
        setState(() {
          _products = Product.listFromJson(response);
          _isLoading = false;
        });
      } else if (response is Map && response['status'] == false) {
        setState(() {
          _error = response['message'] ?? 'Failed to load products';
          _isLoading = false;
        });
      } else {
        setState(() {
          _products = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error =
            'Failed to connect to server. Please check your internet connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final request = context.read<CookieRequest>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final response = await request.logout(ApiConstants.logoutEndpoint);

      if (!mounted) return;

      if (response['status'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppWidgets.successSnackBar('Logged out successfully'));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppWidgets.errorSnackBar(response['message'] ?? 'Logout failed'),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppWidgets.errorSnackBar('Failed to logout. Please try again.'),
      );
    }
  }

  void _handleSearch() => _loadProducts();

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedSort = SortOptions.newest;
      _inStockOnly = false;
    });
    _loadProducts();
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Sort By', style: AppTextStyles.headingMedium),
            ),
            const Divider(),
            ...SortOptions.displayNames.entries.map(
              (entry) => ListTile(
                leading: Icon(
                  _selectedSort == entry.key
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.accentGold,
                ),
                title: Text(entry.value),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedSort = entry.key);
                  _loadProducts();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BECATHLON', style: AppTextStyles.appBarTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Cart',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: AppColors.secondaryBlack,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadProducts();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.accentGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _handleSearch(),
                  onChanged: (value) => setState(() {}),
                ),

                const SizedBox(height: 12),

                // Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (_categories.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: DropdownButtonHideUnderline(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedCategory != null
                                    ? AppColors.accentGoldLight
                                    : AppColors.accentGray,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _selectedCategory != null
                                      ? AppColors.accentGold
                                      : AppColors.subtleBorder,
                                ),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                hint: Text(
                                  'Category',
                                  style: AppTextStyles.bodySecondary,
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.lightGray,
                                ),
                                dropdownColor: AppColors.secondaryBlack,
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      'All Categories',
                                      style: AppTextStyles.bodyPrimary,
                                    ),
                                  ),
                                  ..._categories.map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(
                                        category,
                                        style: AppTextStyles.bodyPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedCategory = value);
                                  _loadProducts();
                                },
                              ),
                            ),
                          ),
                        ),

                      ActionChip(
                        avatar: const Icon(Icons.sort, size: 18),
                        label: Text(
                          SortOptions.displayNames[_selectedSort] ?? 'Sort',
                        ),
                        onPressed: _showSortOptions,
                      ),

                      const SizedBox(width: 8),

                      FilterChip(
                        label: const Text('In Stock'),
                        selected: _inStockOnly,
                        onSelected: (selected) {
                          setState(() => _inStockOnly = selected);
                          _loadProducts();
                        },
                      ),

                      if (_selectedCategory != null ||
                          _inStockOnly ||
                          _selectedSort != SortOptions.newest ||
                          _searchController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ActionChip(
                            avatar: const Icon(Icons.clear, size: 18),
                            label: const Text('Clear'),
                            onPressed: _clearFilters,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: _buildProductContent()),
        ],
      ),
    );
  }

  Widget _buildProductContent() {
    if (_isLoading) {
      return AppWidgets.loadingIndicator(message: 'Loading products...');
    }

    if (_error != null) {
      return AppWidgets.errorState(message: _error!, onRetry: _loadProducts);
    }

    if (_products.isEmpty) {
      return AppWidgets.emptyState(
        title: 'No products found',
        subtitle: 'Try adjusting your filters or search terms',
        action:
            (_selectedCategory != null ||
                _inStockOnly ||
                _searchController.text.isNotEmpty)
            ? TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ProductCard(
            product: product,
            onTap: () => _handleProductTap(product),
          );
        },
      ),
    );
  }
}
