import 'package:biodivcenter/components/info_card.dart';
import 'package:biodivcenter/screens/sanitary_state/edit.dart';
import 'package:flutter/material.dart';

class SanitaryStateDetailsPage extends StatelessWidget {
  const SanitaryStateDetailsPage({super.key, required this.sanitaryState});

  final Map<String, dynamic> sanitaryState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Voir les détails',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            infoCard(
              title: "Détails de l'etat sanitaire :",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow('Etat Sanitaire', sanitaryState['label']),
                  const SizedBox(height: 8),
                  infoRow('Individu', sanitaryState['name']),
                  const SizedBox(height: 8),
                  infoRow('Date', sanitaryState['created_at'].split('T')[0]),
                  const SizedBox(height: 8),
                  infoRow("Description", sanitaryState['description']),
                  const SizedBox(height: 8),
                  infoRow("Action correctif",
                      sanitaryState['correctiveAction'] ?? 'Non défini'),
                  const SizedBox(height: 8),
                  infoRow(
                      "Coût",
                      sanitaryState['cost'] != null
                          ? sanitaryState['cost'].toString()
                          : 'Non défini'),
                  const SizedBox(height: 8),
                  infoRow(
                      "Température",
                      sanitaryState['temperature'].toString() != ""
                          ? sanitaryState['temperature'].toString()
                          : 'Normal'),
                  const SizedBox(height: 8),
                  infoRow(
                      "Taille",
                      sanitaryState['height'] != null
                          ? sanitaryState['height'].toString()
                          : 'Inchangé'),
                  const SizedBox(height: 8),
                  infoRow(
                      "Poids",
                      sanitaryState['weight'] != ''
                          ? sanitaryState['weight'].toString()
                          : 'Inchangé'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditSanitaryState(sanitaryState: sanitaryState),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Editer les informations',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
