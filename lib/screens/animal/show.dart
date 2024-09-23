import 'dart:convert';

import 'package:biodivcenter/components/info_card.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/_animal.dart';
import 'package:biodivcenter/models/_reproduction.dart';
import 'package:biodivcenter/models/_sanitary_state.dart';
import 'package:biodivcenter/screens/animal/edit.dart';
import 'package:biodivcenter/screens/reproduction/show.dart';
import 'package:biodivcenter/screens/sanitary_state/show.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnimalDetailsPage extends StatelessWidget {
  const AnimalDetailsPage({super.key, required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    '$apiBaseUrl/storage/${animal.photo!}',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      animal.specieName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Informations d'identification
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  infoCard(
                    title: "Informations d'identification :",
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        infoRow('Sexe', animal.sex),
                        infoRow('Date de naissance', animal.birthdate),
                        infoRow("Date d'enregistrement", animal.createdAt),
                        infoRow("Poids", '${animal.weight} kg'),
                        infoRow("Taille", '${animal.height}cm'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  infoCard(
                    title: "Informations sur l'origine :",
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        infoRow('Provenance', animal.origin),
                        infoRow('Parent', animal.parent ?? 'Non défini'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  infoCard(
                    title: "Informations sur l'état :",
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        infoRow('État', animal.state),
                        infoRow('Description', animal.description),
                        infoRow('Etat sanitaire', animal.sanitaryStateLabel),
                        infoRow('Observation', animal.sanitaryStateDetail),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Section localisation avec la carte
                  // infoCard(
                  //   title: "Localisation",
                  //   content: Image.asset(
                  //     'assets/images/logo.png', // Remplacer par votre image de carte
                  //     height: 150,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditAnimalPage(animal: animal),
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
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Ombre
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(5, 5), // Position de l'ombre
            ),
          ],
        ),
        margin: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: BottomNavigationBar(
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black,
            onTap: (index) {
              switch (index) {
                case 0:
                  getSanitaryState(context);
                  break;
                case 1:
                  getReproduction(context);
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.health_and_safety),
                label: 'Etat sanitaire',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Reproduction',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getReproduction(context) async {
    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/api/api-reproduction/${animal.id}',
      ),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      Reproduction reproduction = Reproduction.fromJson(jsonResponse);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ReproductionDetailsPage(reproduction: reproduction),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Aucune donnée de reproduction enregistrée pour cet individu.",
          ),
        ),
      );
    }
  }

  Future<void> getSanitaryState(context) async {
    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/api/api-sanitary-state/${animal.id}',
      ),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      SanitaryState sanitaryState = SanitaryState.fromJson(jsonResponse);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              SanitaryStateDetailsPage(sanitaryState: sanitaryState),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Aucune donnée d'état sanitaire enregistrée pour cet individu.",
          ),
        ),
      );
    }
  }
}
