import 'dart:convert';

import 'package:biodivcenter/components/circular_progess_indicator.dart';
import 'package:biodivcenter/components/list_tile.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/Alimentation.dart';
import 'package:biodivcenter/screens/alimentation/create.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AlimentationPage extends StatefulWidget {
  const AlimentationPage({super.key});

  @override
  _AlimentationPageState createState() => _AlimentationPageState();
}

class _AlimentationPageState extends State<AlimentationPage> {
  late Future<List<Alimentation>> _alimentationList;

  // Fonction pour récupérer la liste des alimentations depuis l'API
  Future<List<Alimentation>> fetchAlimentations() async {
    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/api/api-alimentations/${(await SharedPreferences.getInstance()).getInt('site_id')!}',
      ),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((alimentation) => Alimentation.fromJson(alimentation))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _alimentationList = fetchAlimentations();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: FutureBuilder<List<Alimentation>>(
          future: _alimentationList,
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
                  const Text("Aucune alimentation trouvée"),
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
                          Alimentation alimentation = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CustomListTile(
                              title: alimentation.food,
                              subtitle: [alimentation.specieName],
                              onViewPressed: () {
                                // Code pour afficher l'alimentation
                              },
                              onDeletePressed: () {
                                deleteResource(alimentation.id);
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
              'des Alimentations',
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
                builder: (_) => const AddAlimentationPage(),
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
          '$apiBaseUrl/api/api-alimentation/$id',
        ),
      )
          .then((response) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Données supprimées"),
            ),
          );
          setState(() {
            _alimentationList = fetchAlimentations();
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
