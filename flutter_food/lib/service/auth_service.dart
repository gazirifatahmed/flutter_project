import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user.dart';

class AuthService {
  // মোবাইল নেটওয়ার্ক IP ব্যবহার
  final String baseUrl = 'http://192.168.0.107:8080/api/users'; // UPDATED

  // 🔹 Register a new user
  Future<User> register(User user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('❌ Registration failed: ${response.body}');
    }
  }

  // 🔹 Login an existing user
  Future<User> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('✅ Login success: $responseData');
      return User.fromJson(responseData);
    } else {
      print('❌ Login failed: ${response.body}');
      throw Exception('Login failed: ${response.body}');
    }
  }
}
