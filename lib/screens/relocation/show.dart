import 'package:biodivcenter/components/info_card.dart';
import 'package:biodivcenter/models/_relocation.dart';
// import 'package:biodivcenter/screens/relocation/edit.dart';
import 'package:flutter/material.dart';

class RelocationDetailsPage extends StatelessWidget {
  const RelocationDetailsPage({super.key, required this.relocation});

  final Relocation relocation;

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
              title: "Informations d'identification :",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow('Individu', relocation.animalName),
                  infoRow('Date de transfert', relocation.date),
                  infoRow("Enclos d'origine", relocation.penOrigin),
                  infoRow("Enclos destination", relocation.penDestination),
                  infoRow("Commentaire", relocation.comment ?? "Non défini"),
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
                  //         EditRelocationPage(relocation: relocation),
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
}
