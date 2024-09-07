import 'dart:convert';

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
        'http://192.168.192.162:8000/api/individus/site_id=${(await SharedPreferences.getInstance()).getInt('site_id')!}',
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddAnimalPage()));
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
              // Affiche la liste des animaux
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Animal animal = snapshot.data![index];
                  return ListTile(
                    title: Text(animal.name),
                    subtitle: Text("Espèce : ${animal.specie}"),
                    leading: const Icon(Icons.pets),
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
