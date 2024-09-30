import 'dart:convert';
import 'dart:io';

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
    File? imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');

    if (userId == null) {
      return false;
    }

    final url = Uri.parse('$apiBaseUrl/api/user/$userId');

    final request = http.MultipartRequest('POST', url)
      ..fields['id'] = userId.toString()
      ..fields['name'] = name
      ..fields['email'] = email
      ..fields['contact'] = contact;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'picture',
        imageFile.path,
      ));
    }

    final response = await request.send();

    return response.statusCode == 200;
  }
}
