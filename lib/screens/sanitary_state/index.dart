import 'dart:convert';

import 'package:biodivcenter/components/circular_progess_indicator.dart';
import 'package:biodivcenter/components/list_tile.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/SanitaryState.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:biodivcenter/screens/sanitary_state/create.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SanitaryStatePage extends StatefulWidget {
  const SanitaryStatePage({super.key});

  @override
  _SanitaryStatePageState createState() => _SanitaryStatePageState();
}

class _SanitaryStatePageState extends State<SanitaryStatePage> {
  late Future<List<SanitaryState>> _sanitaryStateList;

  // Fonction pour récupérer la liste des états sanitaires depuis l'API
  Future<List<SanitaryState>> fetchSanitaryStates() async {
    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/api/api-sanitary-states/${(await SharedPreferences.getInstance()).getInt('site_id')!}',
      ),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((sanitaryState) => SanitaryState.fromJson(sanitaryState))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _sanitaryStateList = fetchSanitaryStates();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: FutureBuilder<List<SanitaryState>>(
          future: _sanitaryStateList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomCircularProgessIndicator();
            } else if (snapshot.hasError) {
              return Text("Erreur : ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                children: [
                  header(),
                  const SizedBox(height: 20.0),
                  const Text("Aucun état sanitaire trouvé"),
                ],
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    header(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          SanitaryState sanitaryState = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CustomListTile(
                              title: sanitaryState.animalName,
                              subtitle: [sanitaryState.label],
                              onViewPressed: () {
                                // Code pour afficher les détails de l'état sanitaire
                              },
                              onDeletePressed: () {
                                deleteResource(sanitaryState.id);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liste',
              style: TextStyle(
                fontFamily: 'Merriweather',
                color: Color(primaryColor),
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              'des Etats Sanitaires',
              style: TextStyle(
                fontFamily: 'Merriweather',
                color: Color(primaryColor),
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Ajout de la navigation vers la page d'ajout
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddSanitaryState(),
              ),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Ajouter",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }

  void deleteResource(int id) {
    try {
      http
          .delete(
        Uri.parse(
          '$apiBaseUrl/api/api-sanitary-state/$id',
        ),
      )
          .then((response) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Etat sanitaire supprimé"),
            ),
          );
          setState(() {
            _sanitaryStateList = fetchSanitaryStates();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Erreur lors de la suppression"),
            ),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la suppression"),
        ),
      );
      print(e.toString());
    }
  }
}
