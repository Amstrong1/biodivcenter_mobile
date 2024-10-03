import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReproductionSyncService {
  Future<bool> reproductionApi(Map<String, String> fields) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$apiBaseUrl/api/api-reproduction',
        ),
      );

      // Ajouter les champs du formulaire
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Synchronisation réussie pour la reproduction');
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

  Future<void> syncReproductions(BuildContext context) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> reproductions = await db.query(
      'reproductions',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    bool allSyncSuccessful = true;

    // Boucler sur chaque enregistrement pour le synchroniser
    for (var reproduction in reproductions) {
      try {
        Map<String, String> fields = {
          'id': reproduction['id'],
          'ong_id': reproduction['ong_id'],
          'site_id': reproduction['site_id'],
          'user_id': reproduction['user_id'],
          'animal_id': reproduction['animal_id'],
          'phase': reproduction['phase'],
          'litter_size': reproduction['litter_size'].toString(),
          'date': reproduction['date'],
          'observation': reproduction['observation'],
        };

        // Appeler l'API pour synchroniser les données
        bool success = await reproductionApi(fields);

        if (success) {
          await db.update(
            'reproductions',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [reproduction['id']],
          );
        } else {
          allSyncSuccessful = false; // Marquer comme ayant échoué
        }
      } catch (e) {
        if (kDebugMode) {
          print(
            'Erreur lors de la synchronisation de l\'reproduction ${reproduction['id']}: $e',
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
