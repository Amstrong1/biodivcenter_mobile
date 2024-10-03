import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  _makePhoneCall(context, String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de lancer l\'appel.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'A Propos',
                          style: TextStyle(
                            fontFamily: 'Merriweather',
                            color: Color(primaryColor),
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/images/logo.png',
                      width: 150,
                      height: 150,
                    ),
                    const Text(
                      'Règle de confidentialité',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationThickness: 2,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Une préocupation ? Une question ?',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Appelez nous',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        _makePhoneCall(context, '+22965574853');
                      },
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.white,
                      ),
                      label: const Text(
                        '+229 65 57 48 53',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        _makePhoneCall(context, '+22964092320');
                      },
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.white,
                      ),
                      label: const Text(
                        '+229 64 09 23 20',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'ONG du complexe WAP',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bénin, Burkina Faso, Niger',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '@ Copyright 2024',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tous droits réservés',
                      style: TextStyle(
                        fontSize: 13,
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
