import 'dart:convert';

import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<User> fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/user/$userId'),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<bool> updateUser({
    required String name,
    required String email,
    required String contact,
  }) async {
    final url = Uri.parse(
      '$apiBaseUrl/api/user/${(await SharedPreferences.getInstance()).getInt('id')}',
    );

    final response = await http.post(
      url,
      body: {'name': name, 'email': email, 'contact': contact},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
