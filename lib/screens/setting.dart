import 'package:biodivcenter/helpers/alimentation_sync.dart';
import 'package:biodivcenter/helpers/animal_sync.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/helpers/observation_sync.dart';
import 'package:biodivcenter/helpers/reproduction_sync.dart';
import 'package:biodivcenter/helpers/sanitary_state_sync.dart';
import 'package:biodivcenter/helpers/user_service.dart';
import 'package:biodivcenter/models/_user.dart';
import 'package:biodivcenter/screens/account.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late Future<User> _user;
  final UserService _userService = UserService();
  final AnimalSyncService _animalSyncService = AnimalSyncService();
  final ReproductionSyncService _reproductionSyncService = ReproductionSyncService();
  final AlimentationSyncService _alimentationSyncService = AlimentationSyncService();
  final ObservationSyncService _observationSyncService = ObservationSyncService();
  final SanitaryStateSyncService _sanitaryStateSyncService = SanitaryStateSyncService();

  Future<User> getUser() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        return _userService.fetchUser();
      } else {
        Map<String, dynamic> prefs = await getSharedPrefs();

        return User(
          id: prefs['user_id'],
          name: prefs['name'],
          email: prefs['email'],
          contact: prefs['contact'],
          role: prefs['role'],
          ong: prefs['organization'],
          country: prefs['country'],
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _user = getUser();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: FutureBuilder<User>(
          future: _user,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erreur : ${snapshot.error}");
            } else if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    "Une erreur est survenue lors de la récupération des informations de l'utilisateur.",
                  ),
                ],
              );
            } else {
              final user = snapshot.data!;
              return Column(
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
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Color(secondaryColor),
                                  shape: BoxShape.circle,
                                  image: user.picture != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            '$apiBaseUrl/storage/${user.picture}',
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: user.picture == null
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            user.name[0],
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(primaryColor),
                                            ),
                                          )
                                        ],
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.role,
                                      style: TextStyle(
                                        color: Color(primaryColor),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      user.ong,
                                      style: const TextStyle(
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
                          FutureBuilder<bool>(
                            future: checkInternetConnection(),
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasData &&
                                  snapshot.data == true) {
                                return link(
                                  context,
                                  const AccountPage(),
                                  Icons.lock_outline_rounded,
                                  'Compte',
                                  'Informations personnelles, contact',
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          link(
                            context,
                            null,
                            Icons.chat_outlined,
                            'Feedback',
                            'Faites nous vos feedback ici',
                          ),
                          const SizedBox(height: 10),
                          link(
                            context,
                            null,
                            Icons.info_outline,
                            'A propos',
                            'Règle de confidentialité',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      children: [
                        FutureBuilder<bool>(
                          future: checkInternetConnection(),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasData &&
                                snapshot.data == true) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(primaryColor),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                onPressed: () async {
                                  _animalSyncService.syncAnimals();
                                  _reproductionSyncService.syncReproductions();
                                  _alimentationSyncService.syncAlimentations();
                                  _observationSyncService.syncObservations();
                                  _sanitaryStateSyncService.syncSanitaryStates();                                  
                                },
                                child: const Text(
                                  'Synchroniser les données',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'from',
                          style: TextStyle(fontSize: 10),
                        ),
                        Image.asset('assets/images/logo.png', width: 100),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget link(
    context,
    Widget? route,
    IconData icon,
    String title,
    String content,
  ) {
    return TextButton(
      onPressed: () {
        if (route != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => route),
          );
        }
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
