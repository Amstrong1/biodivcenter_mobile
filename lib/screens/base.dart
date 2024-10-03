import 'package:biodivcenter/helpers/auth_provider.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/account.dart';
import 'package:biodivcenter/screens/alimentation/index.dart';
import 'package:biodivcenter/screens/animal/index.dart';
import 'package:biodivcenter/screens/login.dart';
import 'package:biodivcenter/screens/observation/index.dart';
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
        automaticallyImplyLeading: false,
        title: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/images/menu.png',
                      width: 32,
                      height: 32,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                  FutureBuilder<bool>(
                    future: checkInternetConnection(),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasData && snapshot.data == true) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Image.asset(
                              'assets/images/user.png',
                              width: 36,
                              height: 36,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AccountPage(),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
            leading: Icon(Icons.pets, color: Color(primaryColor)),
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
            leading: Icon(Icons.health_and_safety, color: Color(primaryColor)),
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
            leading: Icon(Icons.favorite, color: Color(primaryColor)),
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
            leading: Icon(Icons.local_dining, color: Color(primaryColor)),
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
            leading: Icon(Icons.search, color: Color(primaryColor)),
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
            leading: Icon(Icons.settings, color: Color(primaryColor)),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingPage(),
                ),
              );
            },
          ),
          FutureBuilder<bool>(
            future: checkInternetConnection(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData && snapshot.data == true) {
                return ListTile(
                  leading:
                      Icon(Icons.account_circle, color: Color(primaryColor)),
                  title: const Text('Compte'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AccountPage(),
                      ),
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Color(primaryColor)),
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
