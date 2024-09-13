import 'package:biodivcenter/components/info_card.dart';
import 'package:biodivcenter/models/Reproduction.dart';
// import 'package:biodivcenter/screens/reproduction/edit.dart';
import 'package:flutter/material.dart';

class ReproductionDetailsPage extends StatelessWidget {
  const ReproductionDetailsPage({super.key, required this.reproduction});

  final Reproduction reproduction;

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
              title: "Informations sur la reproduction :",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow('Sexe', reproduction.phase),
                  infoRow('Date', reproduction.date),
                  infoRow("Individu", reproduction.animalName),
                  infoRow("Portée", reproduction.litterSize.toString()),
                  infoRow(
                      "Observation", reproduction.observation ?? "Non défini"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         EditReproductionPage(reproduction: reproduction),
                  //   ),
                  // );
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
