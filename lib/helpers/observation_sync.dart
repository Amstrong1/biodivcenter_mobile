import 'dart:io';

import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class ObservationSyncService {

  Future<bool> observationApi(Map<String, String> fields, File? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$apiBaseUrl/api/api-observation',
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
        print('Synchronisation réussie pour l\'observation');
        return true;
      } else {
        print('Erreur lors de la synchronisation : ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception lors de l\'envoi à l\'API: $e');
      return false;
    }
  }

  Future<void> syncObservations() async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> observations = await db.query(
      'observations',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    // bool allSyncSuccessful = true;

    // Boucler sur chaque enregistrement pour le synchroniser
    for (var observation in observations) {
      try {
        Map<String, String> fields = {
          'ong_id': observation['ong_id'].toString(),
          'site_id': observation['site_id'].toString(),
          'subject': observation['subject'],
          'observation': observation['observation'],
          'slug': observation['slug'],
        };

        // Récupérer la photo (si elle existe)
        File? imageFile;
        if (observation['photo'] != null && observation['photo'].isNotEmpty) {
          imageFile = File(observation['photo']);
        }

        // Appeler l'API pour synchroniser les données
        bool success = await observationApi(fields, imageFile);

        if (success) {
          await db.update(
            'observations',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [observation['id']],
          );
        } else {
          // allSyncSuccessful = false; // Marquer comme ayant échoué
        }
      } catch (e) {
        print(
          'Erreur lors de la synchronisation de l\'observation ${observation['id']}: $e',
        );
        // allSyncSuccessful = false; // Marquer comme ayant échoué
      }
    }

    // Afficher un Snackbar en fonction du succès ou de l'échec
    // if (allSyncSuccessful) {
    //   _showSnackBar(
    //     'Synchronisation réussie de tous les animaux !',
    //     Colors.green,
    //   );
    // } else {
    //   _showSnackBar(
    //     'Certaines synchronisations ont échoué. Veuillez réessayer.',
    //     Colors.red,
    //   );
    // }
  }

  // void _showSnackBar(String message, Color backgroundColor) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: backgroundColor,
  //     ),
  //   );
  // }
}
