import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/store.dart';

class StoreLocatorScreen extends StatefulWidget {
  const StoreLocatorScreen({super.key});

  @override
  State<StoreLocatorScreen> createState() => _StoreLocatorScreenState();
}

class _StoreLocatorScreenState extends State<StoreLocatorScreen> {
  String searchQuery = "";
  Store? selectedStore;

  @override
  Widget build(BuildContext context) {
    final colors = {
      'blue': const Color(0xFF0066FF),
      'blueHover': const Color(0xFF0052CC),
      'border': const Color(0xFF1A1A1A),
      'surface': const Color(0xFF111111),
      'card': const Color(0xFF0D0D0D),
    };

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search Bar
            _buildSearchBar(colors),

            // 🗺 Map Placeholder
            _buildMapPlaceholder(colors),

            // 📍 Store List
            Expanded(child: _buildStoreList(colors)),

            // ⭐ Store Services
            _buildStoreServices(colors),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // 🔍 SEARCH BAR
  // -------------------------------------------------
  Widget _buildSearchBar(Map colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors['border']!)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors['border']!),
        ),
        child: TextField(
          onChanged: (v) => setState(() => searchQuery = v),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search stores...",
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(LucideIcons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // 🗺 MAP PLACEHOLDER
  // -------------------------------------------------
  Widget _buildMapPlaceholder(Map colors) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A)],
        ),
        border: Border(bottom: BorderSide(color: colors['border']!)),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.mapPin, color: colors['blue'], size: 52),
                const SizedBox(height: 8),
                const Text("Interactive Map",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                const Text("Map integration with Google Maps / Mapbox",
                    style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors['border']!),
              ),
              child: const Icon(LucideIcons.navigation, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------
  // 📍 STORE LIST
  // -------------------------------------------------
  Widget _buildStoreList(Map colors) {
    final filtered = demoStores.where((store) {
      final q = searchQuery.toLowerCase();
      return store.name.toLowerCase().contains(q) ||
          store.address.toLowerCase().contains(q) ||
          store.city.toLowerCase().contains(q) ||
          store.country.toLowerCase().contains(q);
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${filtered.length} Stores",
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
              Text("Filter",
                  style: TextStyle(
                      color: colors['blue'], fontSize: 12, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final store = filtered[index];
                final selected = selectedStore?.id == store.id;

                return GestureDetector(
                  onTap: () => setState(() => selectedStore = store),
                  child: _storeCard(store, selected, colors),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // Store card widget adapted to real model fields
  Widget _storeCard(Store s, bool selected, Map colors) {
    // You can compute distance from user later
    final distanceLabel = "Tap for Route";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0D0D), Colors.black],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? colors['blue']! : colors['border']!,
          width: selected ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(s.address,
                        style: const TextStyle(color: Colors.grey)),
                    Text("${s.city}, ${s.country}",
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors['blue'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.mapPin,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(distanceLabel,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Hours row
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(s.storeHours,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),

          const SizedBox(height: 14),

          // Buttons
          Row(
            children: [
              // Directions
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final url = Uri.parse(
                        "https://www.google.com/maps/search/?api=1&query=${s.latitude},${s.longitude}");
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors['blue'],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("GET DIRECTIONS",
                      style:
                          TextStyle(fontSize: 11, letterSpacing: 1)),
                ),
              ),

              const SizedBox(width: 10),

              // No phone in backend → disabled
              Expanded(
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors['surface'],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: Colors.grey.shade900,
                  ),
                  child: const Text("NO PHONE",
                      style: TextStyle(fontSize: 11, letterSpacing: 1)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // -------------------------------------------------
  // ⭐ STORE SERVICES
  // -------------------------------------------------
  Widget _buildStoreServices(Map colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors['border']!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("STORE SERVICES",
              style: TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              serviceBox("🏃", "In-Store Pickup", colors),
              serviceBox("🔧", "Repair Service", colors),
              serviceBox("👕", "Try Before Buy", colors),
              serviceBox("💳", "Easy Returns", colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget serviceBox(String emoji, String text, Map colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF0D0D0D), Colors.black]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors['border']),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, letterSpacing: 1)),
        ],
      ),
    );
  }
}


// Temporary demo stores (replace with REAL result)
final demoStores = [
  Store(
    id: 1,
    name: "Becathlon Jakarta Mega Sport",
    address: "Jl. Sudirman No. 12, Senayan",
    city: "Jakarta",
    country: "Indonesia",
    latitude: -6.21462,
    longitude: 106.84513,
    storeHours: "Mon–Fri: 09:00–21:00\nSat–Sun: 10:00–20:00",
  ),
  Store(
    id: 2,
    name: "Becathlon Surabaya Active Center",
    address: "Jl. Ahmad Yani No. 88, Wonokromo",
    city: "Surabaya",
    country: "Indonesia",
    latitude: -7.25747,
    longitude: 112.75209,
    storeHours: "Mon–Fri: 09:00–21:00\nSat–Sun: 09:00–20:30",
  ),
  Store(
    id: 3,
    name: "Becathlon Bandung FitZone",
    address: "Jl. Asia Afrika No. 25",
    city: "Bandung",
    country: "Indonesia",
    latitude: -6.91746,
    longitude: 107.61912,
    storeHours: "Mon–Fri: 10:00–20:00\nSat–Sun: 09:30–21:00",
  ),
  Store(
    id: 4,
    name: "Becathlon Bali Performance Hub",
    address: "Jl. Sunset Road No. 45",
    city: "Denpasar",
    country: "Indonesia",
    latitude: -8.67046,
    longitude: 115.21263,
    storeHours: "Everyday: 09:00–22:00",
  ),
];
