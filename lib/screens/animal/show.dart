import 'package:biodivcenter/components/info_card.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/Animal.dart';
import 'package:biodivcenter/screens/animal/edit.dart';
import 'package:flutter/material.dart';

class AnimalDetailsPage extends StatelessWidget {
  const AnimalDetailsPage({super.key, required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Image en haut avec un titre et un retour en arrière
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
                        infoRow('Parent', animal.parent),
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
    );
  }

  // Fonction pour créer une carte d'informations
 }
