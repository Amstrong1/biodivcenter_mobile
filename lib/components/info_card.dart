import 'package:biodivcenter/helpers/global.dart';
import 'package:flutter/material.dart';

Widget infoCard({required String title, required Widget content}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Color(accentColor),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const Divider(),
        content,
      ],
    ),
  );
}

// Fonction pour créer une ligne d'informations avec un titre et un contenu
Widget infoRow(String title, String content) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
          ),
          overflow: TextOverflow.visible,
        ),
      ],
    ),
  );
}
