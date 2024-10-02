import 'package:biodivcenter/components/list_tile.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/alimentation/create.dart';
import 'package:biodivcenter/screens/alimentation/edit.dart';
import 'package:biodivcenter/screens/alimentation/show.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:flutter/material.dart';

class AlimentationPage extends StatefulWidget {
  const AlimentationPage({super.key});

  @override
  _AlimentationPageState createState() => _AlimentationPageState();
}

class _AlimentationPageState extends State<AlimentationPage> {
  late Future<List<Map<String, dynamic>>> _alimentationList;

  @override
  void initState() {
    super.initState();
    _alimentationList = DatabaseHelper.instance.getAllAlimentations();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _alimentationList,
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
                  const Text("Aucune alimentation trouvée"),
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
                          final alimentation = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CustomListTile(
                              title: alimentation['food'],
                              subtitle: [alimentation['french_name']],
                              onViewPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AlimentationDetailsPage(
                                      alimentation: alimentation,
                                    ),
                                  ),
                                );
                              },
                              onDeletePressed: () {
                                deleteResource(alimentation['id']);
                              },
                              onEditPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditAlimentationPage(
                                      alimentation: alimentation,
                                    ),
                                  ),
                                );
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
              'des Alimentations',
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
                builder: (_) => const AddAlimentationPage(),
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

  void deleteResource(String id) async {
    try {
      await DatabaseHelper.instance.deleteAlimentation(id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Données supprimées"),
        ),
      );
      setState(() {
        _alimentationList = DatabaseHelper.instance.getAllAlimentations();
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
