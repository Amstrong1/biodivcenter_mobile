import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SanitaryStateSyncService {
  Future<bool> sanitaryStateApi(Map<String, String> fields) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$apiBaseUrl/api/api-sanitary-state',
        ),
      );

      // Ajouter les champs du formulaire
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Synchronisation réussie pour l\'etat sanitaire');
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

  Future<void> syncSanitaryStates(BuildContext context) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> sanitaryStates = await db.query(
      'sanitary_states',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    if (kDebugMode) {
      print(sanitaryStates);
    }

    bool allSyncSuccessful = true;

    // Boucler sur chaque enregistrement pour le synchroniser
    for (var sanitaryState in sanitaryStates) {
      try {
        Map<String, String> fields = {
          'id': sanitaryState['id'],
          'ong_id': sanitaryState['ong_id'],
          'site_id': sanitaryState['site_id'],
          'user_id': sanitaryState['user_id'],
          'animal_id': sanitaryState['animal_id'],
          'label': sanitaryState['label'],
          'description': sanitaryState['description'],
          'corrective_action': sanitaryState['corrective_action'] != ""
              ? sanitaryState['corrective_action']
              : 'Non défini',
          'cost': sanitaryState['cost'] != ""
              ? sanitaryState['cost'].toString()
              : '0',
          'temperature': sanitaryState['temperature'] != ""
              ? sanitaryState['temperature'].toString()
              : '0',
          'weight': sanitaryState['weight'] != ""
              ? sanitaryState['weight'].toString()
              : '0',
        };

        // Appeler l'API pour synchroniser les données
        bool success = await sanitaryStateApi(fields);

        if (success) {
          await db.update(
            'sanitary_states',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [sanitaryState['id']],
          );
        } else {
          allSyncSuccessful = false; // Marquer comme ayant échoué
        }
      } catch (e) {
        if (kDebugMode) {
          print(
          'Erreur lors de la synchronisation de l\'etat sanitaire ${sanitaryState['id']}: $e',
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
