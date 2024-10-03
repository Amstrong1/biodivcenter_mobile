import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/auth_provider.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/animal/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Veuillez',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(primaryColor),
                        fontFamily: 'Merriweather',
                      ),
                    ),
                    Text(
                      'vous identifiez',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(primaryColor),
                        fontFamily: 'Merriweather',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.mail,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        controller: _passwordController,
                        labelText: 'Mot de passe',
                        prefixIcon: Icons.lock,
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                _isSubmitting
                    ? const CircularProgressIndicator() // Affiche l'indicateur de chargement si en cours de soumission
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isSubmitting = true;
                          });
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();

                          // Vérification des entrées utilisateur
                          if (email.isEmpty || password.isEmpty) {
                            setState(() {
                              _isSubmitting = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Veuillez entrer un email et un mot de passe.',
                                ),
                              ),
                            );
                            return;
                          }

                          await context
                              .read<AuthProvider>()
                              .login(email, password);

                          // Redirection vers la page d'accueil après connexion réussie
                          if (context.read<AuthProvider>().isAuthenticated) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AnimalPage(),
                              ),
                            );
                          } else {
                            setState(() {
                              _isSubmitting = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Échec de la connexion.'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
