import 'dart:convert';
import 'package:biodivcenter/helpers/global.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String baseUrl = "$apiBaseUrl/api";

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/signin');
    final response = await http.post(url, body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      // Stockage des informations utilisateur
      await prefs.setString('token', data['access_token']);
      await prefs.setString('tokenType', data['token_type']);
      await prefs.setInt('id', data['user']['id']);
      await prefs.setInt('ong_id', data['user']['ong_id']);
      await prefs.setInt('site_id', data['user']['site_id']);
      await prefs.setString('name', data['user']['name']);

      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final id = prefs.getInt('id');
    final name = prefs.getString('name');

    if (token != null && id != null && name != null) {
      return {'token': token, 'id': id, 'name': name};
    }

    return null;
  }
}
