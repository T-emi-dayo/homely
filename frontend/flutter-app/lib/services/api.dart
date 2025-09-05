import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/house_features.dart';

class ApiClient {
  final http.Client _client;
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<double> predictPrice(HouseFeatures features) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/predict');

    try {
      final res = await _client
          .post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(features.toJson()),
      )
          .timeout(AppConfig.timeout);

      // Debug logging (only runs in debug mode)
      assert(() {
        print("📡 POST $uri => ${res.statusCode}");
        print("📨 Request Body: ${jsonEncode(features.toJson())}");
        print("📬 Response: ${res.body}");
        return true;
      }());

      if (res.statusCode != 200) {
        throw Exception("Server error: ${res.statusCode}");
      }

      final body = jsonDecode(res.body);

      if (body is Map && body['predicted_price'] != null) {
        final num price = body['predicted_price'];
        return price.toDouble();
      } else if (body is Map && body['error'] != null) {
        throw Exception("API Error: ${body['error']}");
      } else {
        throw Exception("Unexpected response: ${res.body}");
      }
    } on TimeoutException {
      throw Exception("Request timed out. Please check your internet connection.");
    } on SocketException {
      throw Exception("No internet connection. Please try again.");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  void close() => _client.close();
}