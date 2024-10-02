import 'package:biodivcenter/components/list_tile.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/animal/create.dart';
import 'package:biodivcenter/screens/animal/edit.dart';
import 'package:biodivcenter/screens/animal/show.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:flutter/material.dart';

class AnimalPage extends StatefulWidget {
  const AnimalPage({super.key});

  @override
  _AnimalPageState createState() => _AnimalPageState();
}

class _AnimalPageState extends State<AnimalPage> {
  late Future<List<Map<String, dynamic>>> _animalList;

  @override
  void initState() {
    super.initState();
    _animalList = DatabaseHelper.instance.getAllAnimals();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _animalList,
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
                  const Text("Aucun animal trouvé"),
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
                          final animal = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CustomListTile(
                              title: animal['name'],
                              subtitle: [animal['french_name'].toString()],
                              onViewPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AnimalDetailsPage(
                                      animal: animal,
                                    ),
                                  ),
                                );
                              },
                              onEditPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditAnimalPage(
                                      animal: animal,
                                    ),
                                  ),
                                );
                              },
                              onDeletePressed: () {
                                deleteResource(animal['id']);
                              },
                              photo: animal['photo'],
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
              'des Individus',
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
                builder: (_) => const AddAnimalPage(),
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

  Future<void> deleteResource(String id) async {
    try {
      await DatabaseHelper.instance.deleteAnimal(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Individu supprimé"),
        ),
      );
      setState(() {
        _animalList = DatabaseHelper.instance.getAllAnimals();
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Erreur lors de la suppression",
          ),
        ),
      );
    }
  }
}
