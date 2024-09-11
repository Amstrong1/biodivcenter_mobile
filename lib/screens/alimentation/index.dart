import 'dart:convert';

import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/Alimentation.dart';
import 'package:biodivcenter/screens/alimentation/create.dart';
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

  // Fonction pour récupérer la liste des animaux depuis l'API
  Future<List<Alimentation>> fetchAlimentations() async {
    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/api/api-alimentations/${(await SharedPreferences.getInstance()).getInt('site_id')!}',
      ),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((alimentation) => Alimentation.fromJson(alimentation)).toList();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alimentation des espèces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAlimentationPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Alimentation>>(
          future: _alimentationList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erreur : ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Aucun alimentation trouvé");
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Alimentation alimentation = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    child: ListTile(
                      tileColor: const Color(0xFFf1f4ef),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      title: Text(alimentation.food),
                      subtitle: Text("Espèce : ${alimentation.specieName}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_red_eye,
                              color: Colors.green,
                              size: 15,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 15,
                            ),
                            onPressed: () {
                              http
                                  .delete(
                                Uri.parse(
                                  '$apiBaseUrl/api/alimentations/${alimentation.id}',
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
                                      content: Text(
                                        "Erreur lors de la suppression",
                                      ),
                                    ),
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
