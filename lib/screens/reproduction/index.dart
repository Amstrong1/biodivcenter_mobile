import 'dart:convert';

import 'package:biodivcenter/components/circular_progess_indicator.dart';
import 'package:biodivcenter/components/list_tile.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/_reproduction.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:biodivcenter/screens/reproduction/create.dart';
import 'package:biodivcenter/screens/reproduction/show.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReproductionPage extends StatefulWidget {
  const ReproductionPage({super.key});

  @override
  _ReproductionPageState createState() => _ReproductionPageState();
}

class _ReproductionPageState extends State<ReproductionPage> {
  late Future<List<Reproduction>> _reproductionList;

  // Fonction pour récupérer la liste des reproductions depuis l'API
  Future<List<Reproduction>> fetchReproductions() async {
    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/api/api-reproductions/${(await SharedPreferences.getInstance()).getInt('site_id')!}',
      ),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((reproduction) => Reproduction.fromJson(reproduction))
          .toList();
    } else {
      throw Exception('Failed to load reproductions');
    }
  }

  @override
  void initState() {
    super.initState();
    _reproductionList = fetchReproductions();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: FutureBuilder<List<Reproduction>>(
          future: _reproductionList,
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
                  const Text("Aucune reproduction trouvée"),
                ],
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0.0,
                  vertical: 0.0,
                ),
                child: Column(
                  children: [
                    header(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          Reproduction reproduction = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CustomListTile(
                              title: reproduction.animalName,
                              subtitle: [reproduction.phase, reproduction.date],
                              onViewPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReproductionDetailsPage(
                                      reproduction: reproduction,
                                    ),
                                  ),
                                );
                              },
                              onEditPressed: () {},
                              onDeletePressed: () {
                                deleteResource(reproduction.id);
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
              'des Reproductions',
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
              MaterialPageRoute(builder: (_) => const AddReproductionPage()),
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
          '$apiBaseUrl/api/api-reproduction/$id',
        ),
      )
          .then((response) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Reproduction supprimée"),
            ),
          );
          setState(() {
            _reproductionList = fetchReproductions();
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
