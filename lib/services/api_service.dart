import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/recipe_api';
    } else {
      return 'http://10.0.2.2/recipe_api';
    }
  }

  // 1. User Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'success': false, 'message': 'Cannot connect to XAMPP Server'};
  }

  // 2. User Register
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'success': false, 'message': 'Cannot connect to XAMPP Server'};
  }

  // 3. Google Sign-In & Register with MySQL
  static Future<Map<String, dynamic>> googleSignIn(String name, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/google_login.php'),
        body: {
          'name': name,
          'email': email,
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'success': false, 'message': 'Cannot connect to XAMPP Server'};
  }

  // 4. Fetch Recipes from MySQL
  static Future<List<Recipe>?> fetchRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_recipes.php'),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List list = data['data'];
          return list.map((item) => Recipe(
            id: item['id'].toString(),
            title: item['title'] ?? '',
            description: item['description'] ?? '',
            prepTime: item['prep_time'] ?? '10 นาที',
            cookTime: item['cook_time'] ?? '15 นาที',
            difficulty: item['difficulty'] ?? 'ง่าย',
            icon: item['icon'] ?? '🍲',
            imageUrl: item['image_url'] ?? '',
            category: item['category_name'] ?? 'Thai',
            ingredients: (item['ingredients'] as List?)?.map((e) => e.toString()).toList() ?? [],
            tools: (item['tools'] as List?)?.map((e) => e.toString()).toList() ?? [],
            steps: (item['steps'] as List?)?.map((e) => e.toString()).toList() ?? [],
            tips: (item['tips'] as List?)?.map((e) => e.toString()).toList() ?? [],
            nutrition: {
              'พลังงาน': item['calories'] ?? '300 kcal',
              'โปรตีน': item['protein'] ?? '15 g',
              'ไขมัน': item['fat'] ?? '12 g',
              'คาร์โบไฮเดรต': item['carbs'] ?? '30 g',
            },
          )).toList();
        }
      }
    } catch (_) {}
    return null;
  }
}
