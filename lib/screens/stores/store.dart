import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // NEW: For the Map
import 'package:latlong2/latlong.dart'; // NEW: For Coordinates
import 'package:url_launcher/url_launcher.dart';
import 'package:becathlon_mobile/utils/styles.dart';
import '../home.dart';
import '../cart_screen.dart';
import '../order_list_screen.dart';
import '../profile_screen.dart';

class Store {
  final int id;
  final String name;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String storeHours;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.storeHours,
  });
}

class StoreLocatorScreen extends StatefulWidget {
  const StoreLocatorScreen({super.key});

  @override
  State<StoreLocatorScreen> createState() => _StoreLocatorScreenState();
}

class _StoreLocatorScreenState extends State<StoreLocatorScreen> {
  static const Color primaryBlack = Color(0xFF0A0A0A);
  static const Color secondaryBlack = Color(0xFF1A1A1A);
  static const Color accentGray = Color(0xFF2A2A2A);
  static const Color lightGray = Color(0xFFA0A0A0);
  static const Color ultraLight = Color(0xFFF5F5F5);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentBlue = Color(0xFF0066FF);

  String _searchQuery = "";
  Store? _selectedStore;
  
  // Controller to move the map programmatically
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlack,
      appBar: AppBar(
        backgroundColor: primaryBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ultraLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'STORE LOCATOR',
          style: TextStyle(
            color: ultraLight,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        // Wrapped in SingleChildScrollView to prevent overflow
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearchBar(),
              _buildInteractiveMap(), // CHANGED: Real Map Widget
              _buildStoreList(),
              _buildStoreServices(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.secondaryBlack,
        selectedItemColor: AppColors.accentGold,
        unselectedItemColor: AppColors.lightGray,
        currentIndex: 1,
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
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderListScreen()),
              );
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: secondaryBlack)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [accentGray, secondaryBlack]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: secondaryBlack),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(color: ultraLight),
          decoration: const InputDecoration(
            hintText: "Search stores...",
            hintStyle: TextStyle(color: lightGray),
            prefixIcon: Icon(Icons.search, color: lightGray),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // NEW: Interactive Map Implementation
  Widget _buildInteractiveMap() {
    return Container(
      height: 250, // Slightly taller for better visibility
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: secondaryBlack)),
      ),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(-6.21462, 106.84513), // Defaults to Jakarta
          initialZoom: 11.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate, // Disable rotation for simplicity
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.becathlon.becathlon_mobile',
          ),
          MarkerLayer(
            markers: _demoStores.map((store) {
              final isSelected = _selectedStore?.id == store.id;
              return Marker(
                point: LatLng(store.latitude, store.longitude),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedStore = store);
                    _mapController.move(
                      LatLng(store.latitude, store.longitude), 
                      14.0
                    );
                  },
                  child: AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.location_on,
                      color: isSelected ? accentBlue : Colors.red,
                      size: 40,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreList() {
    final filtered = _demoStores.where((store) {
      final query = _searchQuery.toLowerCase();
      return store.name.toLowerCase().contains(query) ||
          store.address.toLowerCase().contains(query) ||
          store.city.toLowerCase().contains(query) ||
          store.country.toLowerCase().contains(query);
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${filtered.length} Stores",
                style: const TextStyle(
                  color: ultraLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.filter_list,
                  color: accentBlue,
                  size: 18,
                ),
                label: const Text(
                  "Filter",
                  style: TextStyle(color: accentBlue, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          filtered.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true, // Needed for SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final store = filtered[index];
                    final isSelected = _selectedStore?.id == store.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedStore = store);
                        // Move map to selected store
                        _mapController.move(
                          LatLng(store.latitude, store.longitude), 
                          14.0
                        );
                      },
                      child: _buildStoreCard(store, isSelected),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.store_outlined, size: 48, color: lightGray),
          SizedBox(height: 12),
          Text(
            "No stores found",
            style: TextStyle(color: ultraLight, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            "Try a different search term",
            style: TextStyle(color: lightGray, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(Store store, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [accentGray, primaryBlack],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? accentBlue : secondaryBlack,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        color: ultraLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      store.address,
                      style: const TextStyle(color: lightGray, fontSize: 13),
                    ),
                    Text(
                      "${store.city}, ${store.country}",
                      style: const TextStyle(color: lightGray, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.location_on, color: ultraLight, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "Selected",
                        style: TextStyle(
                          color: ultraLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: lightGray),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  store.storeHours,
                  style: const TextStyle(color: lightGray, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openMaps(store),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text(
                    "GET DIRECTIONS",
                    style: TextStyle(fontSize: 11, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    foregroundColor: ultraLight,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreServices() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: secondaryBlack)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "STORE SERVICES",
            style: TextStyle(
              color: ultraLight,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.6,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildServiceBox(Icons.shopping_bag_outlined, "In-Store Pickup"),
              _buildServiceBox(Icons.build_outlined, "Repair Service"),
              _buildServiceBox(Icons.checkroom_outlined, "Try Before Buy"),
              _buildServiceBox(
                Icons.assignment_return_outlined,
                "Easy Returns",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceBox(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [accentGray, primaryBlack]),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: secondaryBlack),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: accentGold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ultraLight,
                fontSize: 11,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMaps(Store store) async {
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${store.latitude},${store.longitude}",
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open maps"),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }
}

final List<Store> _demoStores = [
  Store(
    id: 1,
    name: "Becathlon Jakarta Mega Sport",
    address: "Jl. Sudirman No. 12, Senayan",
    city: "Jakarta",
    country: "Indonesia",
    latitude: -6.21462,
    longitude: 106.84513,
    storeHours: "Mon-Fri: 09:00-21:00 | Sat-Sun: 10:00-20:00",
  ),
  Store(
    id: 2,
    name: "Becathlon Surabaya Active Center",
    address: "Jl. Ahmad Yani No. 88, Wonokromo",
    city: "Surabaya",
    country: "Indonesia",
    latitude: -7.25747,
    longitude: 112.75209,
    storeHours: "Mon-Fri: 09:00-21:00 | Sat-Sun: 09:00-20:30",
  ),
  Store(
    id: 3,
    name: "Becathlon Bandung FitZone",
    address: "Jl. Asia Afrika No. 25",
    city: "Bandung",
    country: "Indonesia",
    latitude: -6.91746,
    longitude: 107.61912,
    storeHours: "Mon-Fri: 10:00-20:00 | Sat-Sun: 09:30-21:00",
  ),
  Store(
    id: 4,
    name: "Becathlon Bali Performance Hub",
    address: "Jl. Sunset Road No. 45",
    city: "Denpasar",
    country: "Indonesia",
    latitude: -8.67046,
    longitude: 115.21263,
    storeHours: "Everyday: 09:00-22:00",
  ),
];