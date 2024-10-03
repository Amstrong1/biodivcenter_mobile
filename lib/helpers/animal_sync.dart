import 'dart:io';

import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class AnimalSyncService {
  Future<bool> animalApi(Map<String, String> fields, File? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$apiBaseUrl/api/individu',
        ),
      );

      // Ajouter les champs du formulaire
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Ajouter le fichier image s'il existe
      if (imageFile != null && imageFile.existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            imageFile.path,
            filename: basename(imageFile.path),
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Synchronisation réussie pour l\'animal');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Erreur lors de la synchronisation : ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception lors de l\'envoi à l\'API: $e');
      }
      return false;
    }
  }

  Future<void> syncAnimals(BuildContext context) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> animals = await db.query(
      'animals',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    bool allSyncSuccessful = true;

    // Boucler sur chaque enregistrement pour le synchroniser
    for (var animal in animals) {
      try {
        Map<String, String> fields = {
          'id': animal['id'],
          'specie_id': animal['specie_id'],
          'ong_id': animal['ong_id'],
          'site_id': animal['site_id'],
          'name': animal['name'],
          'weight': animal['weight'],
          'height': animal['height'],
          'sex': animal['sex'],
          'birthdate': animal['birthdate'],
          'description': animal['description'],
          'state': animal['state'],
          'origin': animal['origin'] ?? '',
          'parent_id': animal['parent_id'] ?? '',
        };

        // Récupérer la photo (si elle existe)
        File? imageFile;
        if (animal['photo'] != null && animal['photo'].isNotEmpty) {
          imageFile = File(animal['photo']);
        }

        // Appeler l'API pour synchroniser les données
        bool success = await animalApi(fields, imageFile);

        if (success) {
          await db.update(
            'animals',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [animal['id']],
          );
        } else {
          allSyncSuccessful = false; // Marquer comme ayant échoué
        }
      } catch (e) {
        if (kDebugMode) {
          print(
            'Erreur lors de la synchronisation de l\'animal ${animal['id']}: $e',
          );
        }
        allSyncSuccessful = false; // Marquer comme ayant échoué
      }
    }

    // Afficher un Snackbar en fonction du succès ou de l'échec
    if (allSyncSuccessful) {
      _showSnackBar(
        context,
        'Synchronisation réussie !',
        Colors.green,
      );
    } else {
      _showSnackBar(
        context,
        'Certaines synchronisations ont échoué. Veuillez réessayer.',
        Colors.red,
      );
    }
  }

  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
