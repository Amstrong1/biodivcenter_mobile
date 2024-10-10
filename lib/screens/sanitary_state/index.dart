import 'package:biodivcenter/components/list_tile.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:biodivcenter/screens/sanitary_state/create.dart';
import 'package:biodivcenter/screens/sanitary_state/edit.dart';
import 'package:biodivcenter/screens/sanitary_state/show.dart';
import 'package:flutter/material.dart';

class SanitaryStatePage extends StatefulWidget {
  const SanitaryStatePage({super.key});

  @override
  _SanitaryStatePageState createState() => _SanitaryStatePageState();
}

class _SanitaryStatePageState extends State<SanitaryStatePage> {
  late Future<List<Map<String, dynamic>>> _sanitaryStateList;

  @override
  void initState() {
    super.initState();
    _sanitaryStateList = DatabaseHelper.instance.getAllSanitaryStates();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _sanitaryStateList,
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
                  const Text("Aucun état sanitaire trouvé"),
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
                          final sanitaryState = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CustomListTile(
                              title: sanitaryState['name'],
                              subtitle: [
                                sanitaryState['label'],
                                sanitaryState['created_at'].split('T')[0]
                              ],
                              onViewPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SanitaryStateDetailsPage(
                                      sanitaryState: sanitaryState,
                                    ),
                                  ),
                                );
                              },
                              onEditPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditSanitaryState(
                                      sanitaryState: sanitaryState,
                                    ),
                                  ),
                                );
                              },
                              onDeletePressed: () {
                                deleteResource(sanitaryState['id']);
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
              'des Etats Sanitaires',
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
              MaterialPageRoute(
                builder: (_) => const AddSanitaryState(),
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
      await DatabaseHelper.instance.deleteSanitaryState(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Etat sanitaire supprimé"),
        ),
      );
      setState(() {
        _sanitaryStateList = DatabaseHelper.instance.getAllSanitaryStates();
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
