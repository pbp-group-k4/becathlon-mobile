import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store.dart';


class StoreService {
  final String baseUrl = "https://muhammad-vegard-becathlon.pbp.cs.ui.ac.id/stores/api/";

  Future<List<Store>> fetchStores({
    String? query,
    double? lat,
    double? lng,
    double? radius,
  }) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        if (query != null && query.isNotEmpty) "q": query,
        if (lat != null) "lat": lat.toString(),
        if (lng != null) "lng": lng.toString(),
        if (radius != null) "radius": radius.toString(),
      },
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Store API error: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    final list = decoded["results"] as List;

    return list.map((e) => Store.fromJson(e)).toList();
  }
}
