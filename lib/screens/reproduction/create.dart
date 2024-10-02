import 'package:biodivcenter/components/date_field.dart';
import 'package:biodivcenter/components/dropdown_field.dart';
import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/reproduction/index.dart';
import 'package:flutter/material.dart';
import 'package:ulid/ulid.dart';

class AddReproductionPage extends StatefulWidget {
  const AddReproductionPage({super.key});

  @override
  _AddReproductionPageState createState() => _AddReproductionPageState();
}

class _AddReproductionPageState extends State<AddReproductionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _litterSizeController = TextEditingController();
  final TextEditingController _observationController = TextEditingController();
  String? _selectedDate;

  bool _isLoading = false;

  String? _selectedAnimal;
  late Future<List<dynamic>> _animalsList;

  String? _selectedPhase;
  final List<String> _phaseOptions = [
    'Ponte',
    'Eclosion',
    'Mise bas',
  ];

  Future<void> _getLocalAnimals() async {
    setState(() {
      _animalsList = DatabaseHelper.instance.getAnimals();
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocalAnimals();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> prefs = await getSharedPrefs();

      Map<String, dynamic> reproductionData = {
        'id': Ulid().toString(),
        'ong_id': prefs['ong_id'],
        'site_id': prefs['site_id'],
        'user_id': prefs['user_id'],
        'animal_id': _selectedAnimal!,
        'phase': _selectedPhase!,
        'litter_size': _litterSizeController.text,
        'date': _selectedDate!,
        'observation': _observationController.text,
        'is_synced': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await DatabaseHelper.instance.insertReproduction(reproductionData);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reproduction enregistré avec succès !'),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ReproductionPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter une reproduction',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _animalsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune espèce trouvée.'));
          }

          List<dynamic> animalsList = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomDropdown(
                      itemList: animalsList,
                      selectedItem: _selectedAnimal,
                      onChanged: (value) {
                        setState(() {
                          _selectedAnimal = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner un individu';
                        }
                        return null;
                      },
                      label: 'Individu',
                    ),
                    const SizedBox(height: 20),
                    CustomDropdown(
                      itemList: _phaseOptions,
                      selectedItem: _selectedPhase,
                      onChanged: (value) {
                        setState(() {
                          _selectedPhase = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner une phase';
                        }
                        return null;
                      },
                      label: 'Phase',
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _litterSizeController,
                      labelText: 'Portée',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une portée';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Portée invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DatePickerFormField(
                      labelText: 'Date de reproduction',
                      onDateSelected: (selectedDate) {
                        setState(() {
                          _selectedDate = selectedDate;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _observationController,
                      labelText: 'Observation',
                      maxLines: 8,
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
