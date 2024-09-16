import 'package:biodivcenter/components/info_card.dart';
import 'package:biodivcenter/models/_sanitary_state.dart';
// import 'package:biodivcenter/screens/sanitaryState/edit.dart';
import 'package:flutter/material.dart';

class SanitaryStateDetailsPage extends StatelessWidget {
  const SanitaryStateDetailsPage({super.key, required this.sanitaryState});

  final SanitaryState sanitaryState;

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
                  infoRow('Sexe', sanitaryState.label),
                  infoRow('Date de naissance', sanitaryState.animalName),
                  infoRow("Date d'enregistrement", sanitaryState.description),
                  infoRow("Date d'enregistrement",
                      sanitaryState.correctiveAction ?? 'Non défini'),
                  infoRow("Date d'enregistrement", sanitaryState.cost),
                  infoRow("Date d'enregistrement",
                      sanitaryState.temperature.toString()),
                  infoRow(
                      "Date d'enregistrement", sanitaryState.height.toString()),
                  infoRow(
                      "Date d'enregistrement", sanitaryState.weight.toString()),
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
                  //         EditSanitaryStatePage(sanitaryState: sanitaryState),
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
