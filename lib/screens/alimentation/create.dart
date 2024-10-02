import 'package:biodivcenter/components/dropdown_field.dart';
import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/alimentation/index.dart';
import 'package:flutter/material.dart';
import 'package:ulid/ulid.dart';

class AddAlimentationPage extends StatefulWidget {
  const AddAlimentationPage({super.key});

  @override
  _AddAlimentationPageState createState() => _AddAlimentationPageState();
}

class _AddAlimentationPageState extends State<AddAlimentationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  bool _isLoading = false;

  String? _selectedSpecie;
  late Future<List<dynamic>> _speciesList;

  String? _selectedAge;
  final List<String> _ageOptions = [
    'Tout',
    'Jeune',
    'Adolescent',
    'Adulte',
    'Senior'
  ];

  String? _selectedPeriod;
  final List<String> _periodOptions = [
    'Quotidien',
    'Hebdomadaire',
    'Mensuel',
    'Annuel',
  ];

  Future<void> _getLocalSpecies() async {
    setState(() {
      _speciesList = DatabaseHelper.instance.getSpecies();
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> prefs = await getSharedPrefs();

      Map<String, dynamic> alimentationData = {
        'id': Ulid().toString(),
        'ong_id': prefs['ong_id'],
        'site_id': prefs['site_id'],
        'user_id': prefs['user_id'],
        'food': _foodController.text,
        'age_range': _selectedAge!,
        'frequency': _selectedPeriod!,
        'quantity': _quantityController.text,
        'cost': _costController.text,
        'specie_id': _selectedSpecie!,
        'is_synced': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await DatabaseHelper.instance.insertAlimentation(alimentationData);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alimentation enregistré avec succès !'),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AlimentationPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocalSpecies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter une alimentation',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _speciesList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune espèce trouvée.'));
          }

          List<dynamic> speciesList = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: _foodController,
                      labelText: 'Aliment',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un aliment';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomDropdown(
                      itemList: speciesList,
                      selectedItem: _selectedSpecie,
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecie = value;
                        });
                      },
                      label: 'Espèce',
                    ),
                    const SizedBox(height: 20),
                    CustomDropdown(
                      itemList: _ageOptions,
                      selectedItem: _selectedAge,
                      onChanged: (value) {
                        setState(() {
                          _selectedAge = value;
                        });
                      },
                      label: 'Age',
                    ),
                    const SizedBox(height: 20),
                    CustomDropdown(
                      itemList: _periodOptions,
                      selectedItem: _selectedPeriod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                      },
                      label: 'Période',
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _quantityController,
                      labelText: 'Quantité(kg)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une quantité';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _costController,
                      labelText: 'Coût(XOF)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un coût';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: _submitForm,
                            child: const Text(
                              'Enregistrer',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
