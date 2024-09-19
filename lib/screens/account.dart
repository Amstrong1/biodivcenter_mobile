import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/auth_provider.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/helpers/user_service.dart';
import 'package:biodivcenter/models/_user.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:biodivcenter/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<User> _user;
  final UserService _userService = UserService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();

  // bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _user = _userService.fetchUser(); // Appeler la méthode fetchUser
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: FutureBuilder<User>(
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
            final user = snapshot.data!; // Accéder à l'utilisateur récupéré
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Compte',
                              style: TextStyle(
                                fontFamily: 'Merriweather',
                                color: Color(primaryColor),
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.amber),
                          label: const Text(
                            "Editer",
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(accentColor),
                      child: user.picture != null
                          ? Image.network(
                              '$apiBaseUrl/storage/${user.picture}',
                              width: 100,
                              height: 100,
                            )
                          : Text(
                              user.name[0], // Utilisation du snapshot
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(primaryColor),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _nameController..text = user.name,
                      labelText: 'Nom',
                      prefixIcon: Icons.person_outlined,
                      enabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _organizationController..text = user.ong,
                      labelText: 'Organisation',
                      prefixIcon: Icons.business_center_outlined,
                      enabled: false,
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _countryController..text = user.country,
                      labelText: 'Pays',
                      prefixIcon: Icons.location_on_outlined,
                      enabled: false,
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _emailController..text = user.email,
                      labelText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      enabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _contactController..text = user.contact,
                      labelText: 'Contact',
                      prefixIcon: Icons.phone_outlined,
                      enabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre contact';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline_rounded, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Modifier le mot de passe',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Se deconnecter',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
