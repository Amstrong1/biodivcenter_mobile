import 'package:biodivcenter/helpers/global.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final List<String> subtitle;
  final String? photo;
  final VoidCallback onViewPressed;
  final VoidCallback onDeletePressed;

  const CustomListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.photo,
    required this.onViewPressed,
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
              child: Image.network(
                '$apiBaseUrl/storage/${photo!}',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          : const Icon(Icons.pets),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: TextButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(primaryColor),
                backgroundColor: Color(secondaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: onViewPressed,
              child: const Text(
                "Voir",
                style: TextStyle(fontSize: 11),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox(
            width: 50,
            child: TextButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text(
                "Sup",
                style: TextStyle(fontSize: 11),
              ),
              onPressed: onDeletePressed,
            ),
          ),
        ],
      ),
    );
  }
}
