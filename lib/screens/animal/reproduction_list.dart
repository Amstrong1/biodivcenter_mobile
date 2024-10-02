import 'package:biodivcenter/components/list_tile.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/reproduction/create.dart';
import 'package:biodivcenter/screens/reproduction/edit.dart';
import 'package:biodivcenter/screens/reproduction/show.dart';
import 'package:flutter/material.dart';

class AnimalReproductionPage extends StatefulWidget {
  const AnimalReproductionPage({super.key, required this.animalId});

  final String animalId;

  @override
  _ReproductionPageState createState() => _ReproductionPageState();
}

class _ReproductionPageState extends State<AnimalReproductionPage> {
  late Future<List<Map<String, dynamic>>> _reproductionList;

  @override
  void initState() {
    super.initState();
    _reproductionList =
        DatabaseHelper.instance.getReproduction(widget.animalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reproductions',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 32),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddReproductionPage(),
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          right: 32.0,
          left: 32.0,
          top: 32.0,
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _reproductionList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erreur : ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Column(
                children: [
                  SizedBox(height: 20.0),
                  Text("Aucune reproduction trouvée"),
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final reproduction = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CustomListTile(
                              title: reproduction['phase'],
                              subtitle: [reproduction['date']],
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
                              onEditPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditReproductionPage(
                                      reproduction: reproduction,
                                    ),
                                  ),
                                );
                              },
                              onDeletePressed: () {
                                deleteResource(reproduction['id']);
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

  void deleteResource(String id) async {
    try {
      await DatabaseHelper.instance.deleteReproduction(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reproduction supprimée"),
        ),
      );
      setState(() {
        _reproductionList = DatabaseHelper.instance.getAllReproductions();
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la suppression"),
        ),
      );
    }
  }
}
