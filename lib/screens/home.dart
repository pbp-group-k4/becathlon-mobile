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
import 'profile_screen.dart';
import 'stores/store.dart';
import 'recommendations/recommendation_section.dart'; 

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
    // ... (keep your existing logout logic)
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
        ScaffoldMessenger.of(context).showSnackBar(
            AppWidgets.successSnackBar('Logged out successfully'));
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

  // Helper to build the Filter Row with ChoiceChips
  Widget _buildFilterSection() {
    return Container(
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

          // Horizontal Scrollable Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // "All" Category Chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = null);
                        _loadProducts();
                      }
                    },
                    selectedColor: AppColors.accentGold,
                    backgroundColor: AppColors.accentGray,
                    labelStyle: TextStyle(
                      color: _selectedCategory == null
                          ? AppColors.primaryBlack
                          : AppColors.ultraLight,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: _selectedCategory == null
                            ? AppColors.accentGold
                            : AppColors.subtleBorder,
                      ),
                    ),
                  ),
                ),

                // Dynamic Categories
                ..._categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                        _loadProducts();
                      },
                      selectedColor: AppColors.accentGold,
                      backgroundColor: AppColors.accentGray,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primaryBlack
                            : AppColors.ultraLight,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.accentGold
                              : AppColors.subtleBorder,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.lightGray.withOpacity(0.3),
                ),
                const SizedBox(width: 8),

                // Sort Button
                ActionChip(
                  avatar: const Icon(Icons.sort, size: 18),
                  label: Text(
                      SortOptions.displayNames[_selectedSort] ?? 'Sort'),
                  onPressed: _showSortOptions,
                  backgroundColor: AppColors.accentGray,
                  labelStyle: const TextStyle(color: AppColors.ultraLight),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),

                const SizedBox(width: 8),

                // In Stock Filter
                FilterChip(
                  label: const Text('In Stock'),
                  selected: _inStockOnly,
                  onSelected: (selected) {
                    setState(() => _inStockOnly = selected);
                    _loadProducts();
                  },
                  selectedColor: AppColors.accentGold.withOpacity(0.2),
                  checkmarkColor: AppColors.accentGold,
                  backgroundColor: AppColors.accentGray,
                  labelStyle: TextStyle(
                    color: _inStockOnly
                        ? AppColors.accentGold
                        : AppColors.ultraLight,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Note: No standard appBar here. It is inside the CustomScrollView.
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: CustomScrollView(
          slivers: [
            // 1. The Sliver App Bar (Floats and snaps)
            SliverAppBar(
              title: Text('BECATHLON', style: AppTextStyles.appBarTitle),
              centerTitle: true,
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: AppColors.secondaryBlack.withOpacity(0.95),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.store),
                tooltip: 'Store Locator',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StoreLocatorScreen()),
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person),
                  tooltip: 'Profile',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Cart',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CartScreen()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.receipt_long),
                  tooltip: 'My Orders',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrderListScreen()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: _handleLogout,
                ),
              ],
            ),

            // 2. Search & Filter Section
            SliverToBoxAdapter(
              child: _buildFilterSection(),
            ),

            // 3. Recommendation Section (Only visible on main view)
            if (_searchController.text.isEmpty && _selectedCategory == null)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: RecommendationSection(
                    title: "Featured For You",
                  ),
                ),
              ),

            // 4. Content State Handling (Loading / Error / Empty / Grid)
            if (_isLoading)
              SliverFillRemaining(
                child: AppWidgets.loadingIndicator(message: 'Loading products...'),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: AppWidgets.errorState(
                  message: _error!,
                  onRetry: _loadProducts,
                ),
              )
            else if (_products.isEmpty)
              SliverFillRemaining(
                child: AppWidgets.emptyState(
                  title: 'No products found',
                  subtitle: 'Try adjusting your filters or search terms',
                  action: (_selectedCategory != null ||
                          _inStockOnly ||
                          _searchController.text.isNotEmpty)
                      ? TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Filters'),
                        )
                      : null,
                ),
              )
            else
              // 5. The Product Grid
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = _products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _handleProductTap(product),
                      );
                    },
                    childCount: _products.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}