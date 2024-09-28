library biodivcenter.helpers.global;

import 'dart:io';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

String apiBaseUrl = "http://192.168.149.162:8000";

int primaryColor = 0xff1e9a2c;
int secondaryColor = 0xffddf3d1;
int accentColor = 0xfff1f4ef;

Future<List<dynamic>> getLocalSpecies() async {
  return await DatabaseHelper.instance.getSpecies();
}

Future<void> fetchAndSaveSpecies() async {
  try {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/species-list'));

    if (response.statusCode == 200) {
      List speciesList = json.decode(response.body);

      // Préparer les données pour SQLite
      List<Map<String, dynamic>> speciesData = speciesList.map((species) {
        return {
          'id': species['id'],
          'scientific_name': species['scientific_name'],
          'french_name': species['french_name'],
          'status_uicn': species['status_uicn'],
          'status_cites': species['status_cites'],
          'uicn_link': species['uicn_link'],
          'inaturalist_link': species['inaturalist_link'],
        };
      }).toList();

      // Insérer dans la base de données locale
      for (var specieData in speciesData) {
        await DatabaseHelper.instance.insertSpecies(specieData);
      }
    } else {
      print('Erreur lors de la récupération des données depuis l\'API');
    }
  } catch (e) {
    print('Erreur réseau : $e');
  }
}

Future<void> requestPermissions() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
}

Future<File> saveImageLocally(File image) async {
  final directory = await getApplicationDocumentsDirectory();
  final imagePath = join(directory.path, basename(image.path));
  return File(image.path).copy(imagePath);
}

Future<Map<String, dynamic>> getSharedPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'ong_id': prefs.getInt('ong_id'),
    'site_id': prefs.getInt('site_id'),
    'user_id': prefs.getInt('id'),
    'name': prefs.getString('name'),
    'email': prefs.getString('email'),
    'contact': prefs.getString('contact'),
    'role': prefs.getString('role'),
    'organization': prefs.getString('organization'),
    'country': prefs.getString('country'),
  };
}

buildImagePicker(selectImage, selectedImage) {
  return GestureDetector(
    onTap: selectImage,
    child: Container(
      width: 100,
      height: 100,
      color: Colors.grey[200],
      child: selectedImage != null
          ? Image.file(selectedImage!, fit: BoxFit.cover)
          : const Icon(Icons.add_a_photo, size: 50),
    ),
  );
}

Future<bool> checkInternetConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}
