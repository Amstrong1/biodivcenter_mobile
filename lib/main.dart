import 'package:biodivcenter/helpers/auth_provider.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  Map<String, dynamic> prefs = await getSharedPrefs();

  if (prefs['user_id'] == null) {
      await requestPermissions();    
  }

  await DatabaseHelper.instance.database;
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
          ),
        ),
        // debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
