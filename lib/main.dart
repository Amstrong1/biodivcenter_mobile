import 'package:biodivcenter/helpers/auth_provider.dart';
import 'package:biodivcenter/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..checkAuthStatus(),
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff1e9a2c),
            brightness: Brightness.light,
          ),
        ),
        // debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
