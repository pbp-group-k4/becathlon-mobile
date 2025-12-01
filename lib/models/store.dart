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

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json["id"],
      name: json["name"],
      address: json["address"],
      city: json["city"],
      country: json["country"],
      latitude: json["latitude"]?.toDouble() ?? 0.0,
      longitude: json["longitude"]?.toDouble() ?? 0.0,
      storeHours: json["store_hours"] ?? "",
    );
  }
}
