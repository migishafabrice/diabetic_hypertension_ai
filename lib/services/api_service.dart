import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? get baseUrl => dotenv.env['BACKEND_API_URL'];

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> syncData(Map<String, dynamic> syncPayload) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: headers,
        body: jsonEncode(syncPayload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to sync: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Sync error: $e');
    }
  }

  Future<Map<String, dynamic>> getAIRecommendations(int userId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/ai/recommendations'),
            headers: headers,
            body: jsonEncode({'user_id': userId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get recommendations: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Backend AI request timed out after 10 seconds');
    } catch (e) {
      throw Exception('Recommendations error: $e');
    }
  }

  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  Future<Map<String, dynamic>> loginUser(Map<String, dynamic> credentials) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: jsonEncode(credentials),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
}
