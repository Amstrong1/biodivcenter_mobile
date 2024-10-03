library biodivcenter.helpers.global;

import 'dart:io';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ulid/ulid.dart';

String apiBaseUrl = "http://192.168.149.162:8000";

int primaryColor = 0xff1e9a2c;
int secondaryColor = 0xffddf3d1;
int accentColor = 0xfff1f4ef;

Future<Map<String, dynamic>> getSharedPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'ong_id': prefs.getString('ong_id'),
    'site_id': prefs.getString('site_id'),
    'user_id': prefs.getString('id'),
    'name': prefs.getString('name'),
    'email': prefs.getString('email'),
    'contact': prefs.getString('contact'),
    'role': prefs.getString('role'),
    'organization': prefs.getString('organization'),
    'country': prefs.getString('country'),
  };
}

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
          'french_name': species['french_name'],
        };
      }).toList();

      // Insérer dans la base de données locale
      for (var specieData in speciesData) {
        await DatabaseHelper.instance.insertSpecies(specieData);
      }
    } else {
      if (kDebugMode) {
        print('Erreur lors de la récupération des données depuis l\'API');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erreur réseau : $e');
    }
  }
}

Future<void> fetchAndSaveAnimals() async {
  try {
    Map<String, dynamic> prefs = await getSharedPrefs();

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/individus/${prefs["site_id"]}'),
    );

    if (response.statusCode == 200) {
      List animalsList = json.decode(response.body);

      // Préparer les données pour SQLite
      List<Map<String, dynamic>> animalsData = animalsList.map((animals) {
        return {
          'id': Ulid().toString(),
          'specie_id': animals['specie_id'],
          'ong_id': animals['ong_id'],
          'site_id': animals['site_id'],
          'name': animals['name'],
          'weight': animals['weight'],
          'height': animals['height'],
          'sex': animals['sex'],
          'birthdate': animals['birthdate'],
          'description': animals['description'],
          'state': animals['state'],
          'origin': animals['origin'],
          'parent_id': animals['parent_id'],
          'photo': animals['photo'],
          'created_at': animals['created_at'],
          'updated_at': animals['updated_at'],
          'is_synced': 1,
        };
      }).toList();

      // Insérer dans la base de données locale
      for (var animalData in animalsData) {
        if (animalData['photo'] != null) {
          File savedImage = await saveImageLocally(animalData['photo']!);
          animalData = {...animalData, 'photo': savedImage.path};
        }
        await DatabaseHelper.instance.insertAnimal(animalData);
      }
    } else {
      if (kDebugMode) {
        print('Erreur lors de la récupération des données depuis l\'API');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erreur réseau : $e');
    }
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

Future<bool> checkInternetConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}
