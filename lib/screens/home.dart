import 'package:biodivcenter/helpers/auth_provider.dart';
import 'package:biodivcenter/screens/alimentation/index.dart';
import 'package:biodivcenter/screens/animal/index.dart';
import 'package:biodivcenter/screens/login.dart';
import 'package:biodivcenter/screens/observation/index.dart';
import 'package:biodivcenter/screens/relocation/index.dart';
import 'package:biodivcenter/screens/reproduction/index.dart';
import 'package:biodivcenter/screens/sanitary_state/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    AnimalPage(),
    SanitaryStatePage(),
    ReproductionPage(),
    AlimentationPage(),
    RelocationPage(),
    ObservationPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiodivCenter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFF1e9a2c),
      ),
      body: Center(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey.shade400,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Animal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'État Sanitaire',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Reproduction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_dining),
            label: 'Alimentation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.move_down),
            label: 'Transfert',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Observation',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
