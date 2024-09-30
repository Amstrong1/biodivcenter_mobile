import 'dart:io';

import 'package:biodivcenter/helpers/global.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final List<String> subtitle;
  final String? photo;
  final VoidCallback onViewPressed;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const CustomListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.photo,
    required this.onViewPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Color(accentColor),
      contentPadding: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: RichText(
        text: TextSpan(
          text: subtitle[0],
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: subtitle.length > 1 ? ' - ${subtitle[1]}' : '',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      leading: photo != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(photo!),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          : const Icon(Icons.pets),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showModal(context);
            },
          ),
        ],
      ),
      onTap: onViewPressed,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: onEditPressed,
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.edit, color: Colors.amber),
                    SizedBox(width: 20),
                    Text(
                      'Modifier',
                      style: TextStyle(color: Colors.amber, fontSize: 18.0),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _showConfirmationDialog(context);
                },
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 20),
                    Text(
                      'Supprimer',
                      style: TextStyle(color: Colors.red, fontSize: 18.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content:
              const Text('Etes-vous sûr de vouloir supprimer cet élément ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmer'),
              onPressed: () {
                onDeletePressed();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
