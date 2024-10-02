import 'package:biodivcenter/components/list_tile.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:biodivcenter/screens/reproduction/create.dart';
import 'package:biodivcenter/screens/reproduction/edit.dart';
import 'package:biodivcenter/screens/reproduction/show.dart';
import 'package:flutter/material.dart';

class ReproductionPage extends StatefulWidget {
  const ReproductionPage({super.key});

  @override
  _ReproductionPageState createState() => _ReproductionPageState();
}

class _ReproductionPageState extends State<ReproductionPage> {
  late Future<List<Map<String, dynamic>>> _reproductionList;

  @override
  void initState() {
    super.initState();
    _reproductionList = DatabaseHelper.instance.getAllReproductions();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _reproductionList,
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
                          final reproduction = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CustomListTile(
                              title: reproduction['name'],
                              subtitle: [
                                reproduction['phase'],
                                reproduction['date']
                              ],
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
