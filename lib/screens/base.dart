import 'package:biodivcenter/helpers/auth_provider.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/account.dart';
import 'package:biodivcenter/screens/alimentation/index.dart';
import 'package:biodivcenter/screens/animal/index.dart';
import 'package:biodivcenter/screens/login.dart';
import 'package:biodivcenter/screens/observation/index.dart';
import 'package:biodivcenter/screens/relocation/index.dart';
import 'package:biodivcenter/screens/reproduction/index.dart';
import 'package:biodivcenter/screens/sanitary_state/index.dart';
import 'package:biodivcenter/screens/setting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;

  const BaseScaffold({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.green,
                  size: 50,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.black,
                size: 50,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.only(
          right: 32.0,
          left: 32.0,
          top: 32.0,
        ),
        child: body,
      ),
    );
  }
}

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const SizedBox(
            height: 150,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    image: AssetImage('assets/images/logo.png'),
                    width: 150,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text('Individus'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AnimalPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: const Text('État Sanitaire'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SanitaryStatePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Reproduction'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ReproductionPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_dining),
            title: const Text('Alimentation'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AlimentationPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.move_down),
            title: const Text('Transfert'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RelocationPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Observation'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ObservationPage(),
                ),
              );
            },
          ),
          Divider(
            thickness: 2,
            indent: 20,
            endIndent: 100,
            color: Color(primaryColor),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Compte'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AccountPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Déconnexion'),
            onTap: () async {
              await context.read<AuthProvider>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
