import 'dart:convert';

import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/Reproduction.dart';
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

  // Fonction pour récupérer la liste des animaux depuis l'API
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Animaux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => const AddReproductionPage()),
              // );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Reproduction>>(
          future: _reproductionList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erreur : ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Aucun reproduction trouvé");
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Reproduction reproduction = snapshot.data![index];
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
                      title: Text(reproduction.animalName),
                      subtitle: RichText(
                        text: TextSpan(
                          text: reproduction.phase,
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: ' - ${reproduction.date}',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
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
                                  '$apiBaseUrl/api/api-reproductions/${reproduction.id}',
                                ),
                              )
                                  .then((response) {
                                if (response.statusCode == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Individu supprimé"),
                                    ),
                                  );
                                  setState(() {
                                    _reproductionList = fetchReproductions();
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
