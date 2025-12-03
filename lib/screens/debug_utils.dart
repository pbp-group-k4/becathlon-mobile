import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Helper to perform raw HTTP requests and log results for debugging
Future<Map<String, dynamic>> debugPostJson(
  String url,
  Map<String, dynamic> body,
) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    if (kDebugMode) {
      print(
        'debugPostJson => status: ${response.statusCode}, body: ${response.body}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  } catch (e) {
    if (kDebugMode) {
      print('debugPostJson error => ${e.toString()}');
    }
    rethrow;
  }
}

Future<Map<String, dynamic>> debugPostForm(
  String url,
  Map<String, String> body,
) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: body,
    );
    if (kDebugMode) {
      print(
        'debugPostForm => status: ${response.statusCode}, body: ${response.body}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  } catch (e) {
    if (kDebugMode) print('debugPostForm error => ${e.toString()}');
    rethrow;
  }
}
