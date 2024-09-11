import 'dart:convert';

import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/SanitaryState.dart';
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

  // Fonction pour récupérer la liste des animaux depuis l'API
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etats sanitaires enregistrés'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => const AddSanitaryStatePage()),
              // );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<SanitaryState>>(
          future: _sanitaryStateList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erreur : ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Aucune donnée trouvée");
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  SanitaryState sanitaryState = snapshot.data![index];
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
                      title: Text(sanitaryState.animalName),
                      subtitle: Text(
                        sanitaryState.label,
                        style: const TextStyle(color: Colors.black),
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
                                  '$apiBaseUrl/api/api-sanitary-state/${sanitaryState.id}',
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
                                    _sanitaryStateList = fetchSanitaryStates();
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
