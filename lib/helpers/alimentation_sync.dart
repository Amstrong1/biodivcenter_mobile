import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:http/http.dart' as http;

class AlimentationSyncService {

  Future<bool> alimentationApi(Map<String, String> fields) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$apiBaseUrl/api/api-alimentation',
        ),
      );

      // Ajouter les champs du formulaire
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Synchronisation réussie pour l\'alimentation');
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

  Future<void> syncAlimentations() async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> alimentations = await db.query(
      'alimentations',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    // bool allSyncSuccessful = true;

    // Boucler sur chaque enregistrement pour le synchroniser
    for (var alimentation in alimentations) {
      try {
        Map<String, String> fields = {
          'ong_id': alimentation['ong_id'].toString(),
          'site_id': alimentation['site_id'].toString(),
          'user_id': alimentation['user_id'].toString(),
          'food': alimentation['food'],
          'age_range': alimentation['age_range'],
          'frequency': alimentation['frequency'],
          'quantity': alimentation['quantity'],
          'specie_id': alimentation['specie_id'],
          'cost': alimentation['cost'],
          'slug': alimentation['slug'],
        };

        // Appeler l'API pour synchroniser les données
        bool success = await alimentationApi(fields);

        if (success) {
          await db.update(
            'alimentations',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [alimentation['id']],
          );
        } else {
          // allSyncSuccessful = false; // Marquer comme ayant échoué
        }
      } catch (e) {
        print(
          'Erreur lors de la synchronisation de l\'alimentation ${alimentation['id']}: $e',
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
