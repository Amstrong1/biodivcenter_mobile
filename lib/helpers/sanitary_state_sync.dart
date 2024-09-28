import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
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
        print('Synchronisation réussie pour l\'sanitaryState');
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

  Future<void> syncSanitaryStates() async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> sanitaryStates = await db.query(
      'sanitary_states',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    // bool allSyncSuccessful = true;

    // Boucler sur chaque enregistrement pour le synchroniser
    for (var sanitaryState in sanitaryStates) {
      try {
        Map<String, String> fields = {
          'ong_id': sanitaryState['ong_id'].toString(),
          'site_id': sanitaryState['site_id'].toString(),
          'user_id': sanitaryState['user_id'].toString(),
          'animal_id': sanitaryState['animal_id'],
          'label': sanitaryState['label'],
          'description': sanitaryState['description'],
          'corrective_action': sanitaryState['corrective_action'],
          'cost': sanitaryState['cost'],
          'temperature': sanitaryState['temperature'],
          'height': sanitaryState['height'],
          'weight': sanitaryState['weight'],
          'slug': sanitaryState['slug'],
        };

        // Appeler l'API pour synchroniser les données
        bool success = await sanitaryStateApi(fields);

        if (success) {
          await db.update(
            'sanitaryStates',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [sanitaryState['id']],
          );
        } else {
          // allSyncSuccessful = false; // Marquer comme ayant échoué
        }
      } catch (e) {
        print(
          'Erreur lors de la synchronisation de l\'sanitaryState ${sanitaryState['id']}: $e',
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
