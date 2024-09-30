import 'package:biodivcenter/components/info_card.dart';
import 'package:biodivcenter/screens/alimentation/edit.dart';
import 'package:flutter/material.dart';

class AlimentationDetailsPage extends StatelessWidget {
  const AlimentationDetailsPage({super.key, required this.alimentation});

  final Map<String, dynamic> alimentation;

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
            infoCard(
              title: "Informations sur l'espèce :",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow('Espece', alimentation['french_name']),
                  const SizedBox(height: 8),
                  infoRow('Age', alimentation['age_range']),
                ],
              ),
            ),
            const SizedBox(height: 10),
            infoCard(
              title: "Informations sur l'aliment :",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow('Aliment', alimentation['food']),
                  const SizedBox(height: 8),
                  infoRow('Fréquence', alimentation['frequency']),
                  const SizedBox(height: 8),
                  infoRow('Quantité', '${alimentation['quantity']} kg'),
                  const SizedBox(height: 8),
                  infoRow('Coût', alimentation['cost'].toString()),
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
                          EditAlimentationPage(alimentation: alimentation),
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

  // Fonction pour créer une carte d'informations
}
