import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/account.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paramètres',
                            style: TextStyle(
                              fontFamily: 'Merriweather',
                              color: Color(primaryColor),
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(accentColor),
                        child: Text(
                          'AD',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin',
                              style: TextStyle(
                                color: Color(primaryColor),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Espace Vert et Développement',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  link(
                    const AccountPage(),
                    Icons.lock_outline_rounded,
                    'Compte',
                    'Informations personnelles, contact',
                  ),
                  const SizedBox(height: 10),
                  link(
                    null,
                    Icons.chat_outlined,
                    'Feedback',
                    'Faites nous vos feedback ici',
                  ),
                  const SizedBox(height: 10),
                  link(
                    null,
                    Icons.info_outline,
                    'A propos',
                    'Règle de confidentialité',
                  ),
                ],
              ),
            ),
          ),
          // Section contenant "from" et le logo fixée en bas de la page
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              children: [
                const Text(
                  'from',
                  style: TextStyle(fontSize: 10),
                ),
                Image.asset('assets/images/logo.png', width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget link(Widget? route, IconData icon, String title, String content) {
    return TextButton(
      onPressed: () {
        route != null
            ? Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => route))
            : null;
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 35),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
