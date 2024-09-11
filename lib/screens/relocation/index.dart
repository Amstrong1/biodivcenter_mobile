import 'dart:convert';

import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/Relocation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RelocationPage extends StatefulWidget {
  const RelocationPage({super.key});

  @override
  _RelocationPageState createState() => _RelocationPageState();
}

class _RelocationPageState extends State<RelocationPage> {
  late Future<List<Relocation>> _relocationList;

  // Fonction pour récupérer la liste des animaux depuis l'API
  Future<List<Relocation>> fetchRelocations() async {
    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/api/api-relocations/${(await SharedPreferences.getInstance()).getInt('site_id')!}',
      ),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((relocation) => Relocation.fromJson(relocation)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _relocationList = fetchRelocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relocation des espèces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => const AddRelocationPage()),
              // );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Relocation>>(
          future: _relocationList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erreur : ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Aucune relocation trouvé");
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Relocation relocation = snapshot.data![index];
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
                      title: Text(relocation.animalName),
                      subtitle: Text("Date : ${relocation.date}"),
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
                                  '$apiBaseUrl/api/relocations/${relocation.id}',
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
                                    _relocationList = fetchRelocations();
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
