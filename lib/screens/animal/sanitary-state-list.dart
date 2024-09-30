import 'package:biodivcenter/components/list_tile.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/sanitary_state/create.dart';
import 'package:biodivcenter/screens/sanitary_state/edit.dart';
import 'package:biodivcenter/screens/sanitary_state/show.dart';
import 'package:flutter/material.dart';

class AnimalSanitaryStatePage extends StatefulWidget {
  const AnimalSanitaryStatePage({super.key, required this.animalId});

  final int animalId;

  @override
  _SanitaryStatePageState createState() => _SanitaryStatePageState();
}

class _SanitaryStatePageState extends State<AnimalSanitaryStatePage> {
  late Future<List<Map<String, dynamic>>> _sanitaryStateList;

  @override
  void initState() {
    super.initState();
    _sanitaryStateList =
        DatabaseHelper.instance.getSanitaryState(widget.animalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Etats sanitaires',
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
          future: _sanitaryStateList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erreur : ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Column(
                children: [
                  SizedBox(height: 20.0),
                  Text("Aucun état sanitaire trouvé"),
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
                          final sanitaryState = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CustomListTile(
                              title: sanitaryState['label'],
                              subtitle: [
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

  void deleteResource(int id) async {
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
