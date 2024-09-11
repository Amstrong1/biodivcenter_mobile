import 'dart:convert';

import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/Animal.dart';
import 'package:biodivcenter/screens/animal/create.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AnimalPage extends StatefulWidget {
  const AnimalPage({super.key});

  @override
  _AnimalPageState createState() => _AnimalPageState();
}

class _AnimalPageState extends State<AnimalPage> {
  late Future<List<Animal>> _animalList;

  // Fonction pour récupérer la liste des animaux depuis l'API
  Future<List<Animal>> fetchAnimals() async {
    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/api/individus/${(await SharedPreferences.getInstance()).getInt('site_id')!}',
      ),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((animal) => Animal.fromJson(animal)).toList();
    } else {
      throw Exception('Failed to load animals');
    }
  }

  @override
  void initState() {
    super.initState();
    _animalList = fetchAnimals();
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAnimalPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Animal>>(
          future: _animalList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erreur : ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Aucun animal trouvé");
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Animal animal = snapshot.data![index];
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
                      title: Text(animal.name),
                      subtitle: Text(animal.specieName),
                      leading: animal.photo != null
                          ? Image.network(
                              '$apiBaseUrl/storage/${animal.photo!}',
                            )
                          : const Icon(Icons.pets),
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
                                  '$apiBaseUrl/api/individus/${animal.id}',
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
                                    _animalList = fetchAnimals();
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
