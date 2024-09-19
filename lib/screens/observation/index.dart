import 'dart:convert';

import 'package:biodivcenter/components/list_tile.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/_observation.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:biodivcenter/screens/observation/create.dart';
import 'package:biodivcenter/screens/observation/edit.dart';
import 'package:biodivcenter/screens/observation/show.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ObservationPage extends StatefulWidget {
  const ObservationPage({super.key});

  @override
  _ObservationPageState createState() => _ObservationPageState();
}

class _ObservationPageState extends State<ObservationPage> {
  late Future<List<Observation>> _observationList;

  // Fonction pour récupérer la liste des observations depuis l'API
  Future<List<Observation>> fetchObservations() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? siteId = prefs.getInt('site_id');

    if (siteId == null) {
      throw Exception('Le site n\'est pas défini');
    }

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/api-observations/$siteId'),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((observation) => Observation.fromJson(observation))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _observationList = fetchObservations();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: FutureBuilder<List<Observation>>(
          future: _observationList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erreur : ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                children: [
                  header(),
                  const SizedBox(height: 20.0),
                  const Text("Aucune observation trouvée"),
                ],
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 0,
                ),
                child: Column(
                  children: [
                    header(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          Observation observation = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: CustomListTile(
                              title: observation.subject,
                              subtitle: [observation.date],
                              onViewPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ObservationDetailsPage(
                                      observation: observation,
                                    ),
                                  ),
                                );
                              },
                              onEditPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditObservationPage(
                                      observation: observation,
                                    ),
                                  ),
                                );
                              },
                              onDeletePressed: () {
                                deleteResource(observation.id);
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
              'des observations',
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddObservationPage(),
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
        Uri.parse('$apiBaseUrl/api/api-observation/$id'),
      )
          .then(
        (response) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Observation supprimée"),
            ),
          );
          setState(() {
            _observationList = fetchObservations();
          });
        },
      );
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
