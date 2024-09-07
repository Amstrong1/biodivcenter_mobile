import 'package:biodivcenter/helpers/auth_provider.dart';
import 'package:biodivcenter/screens/home.dart';
import 'package:biodivcenter/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          // Si l'utilisateur est authentifié, redirige vers la page d'accueil
          Future.microtask(() => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen())));
        } else {
          // Sinon, redirige vers la page de connexion
          Future.microtask(() => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LoginScreen())));
        }

        // Pendant que l'authentification est en cours de vérification, affiche un écran temporaire
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
