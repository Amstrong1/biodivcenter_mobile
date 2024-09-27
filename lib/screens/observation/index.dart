import 'package:biodivcenter/components/list_tile.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:biodivcenter/screens/observation/create.dart';
import 'package:biodivcenter/screens/observation/edit.dart';
import 'package:biodivcenter/screens/observation/show.dart';
import 'package:flutter/material.dart';

class ObservationPage extends StatefulWidget {
  const ObservationPage({super.key});

  @override
  _ObservationPageState createState() => _ObservationPageState();
}

class _ObservationPageState extends State<ObservationPage> {
  late Future<List<Map<String, dynamic>>> _observationList;

  @override
  void initState() {
    super.initState();
    _observationList = DatabaseHelper.instance.getAllObservations();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _observationList,
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
                  const Text("Aucune observation trouvée"),
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
                          final observation = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: CustomListTile(
                              title: observation['subject'],
                              subtitle: [
                                observation['created_at'].split('T')[0]
                              ],
                              onViewPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ObservationDetailsPage(
                                      observation: observation,
                                    ),
                                  ),
                                );
                              },
                              onEditPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditObservationPage(
                                      observation: observation,
                                    ),
                                  ),
                                );
                              },
                              onDeletePressed: () {
                                deleteResource(observation['id']);
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
              'des observations',
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
                builder: (_) => const AddObservationPage(),
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

  void deleteResource(int id) async {
    try {
      await DatabaseHelper.instance.deleteObservation(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Observation supprimée"),
        ),
      );
      setState(() {
        _observationList = DatabaseHelper.instance.getAllObservations();
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
