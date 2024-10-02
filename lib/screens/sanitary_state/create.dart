import 'package:biodivcenter/components/dropdown_field.dart';
import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/sanitary_state/index.dart';
import 'package:flutter/material.dart';
import 'package:ulid/ulid.dart';

class AddSanitaryState extends StatefulWidget {
  const AddSanitaryState({super.key});

  @override
  AddSanitaryStatePage createState() => AddSanitaryStatePage();
}

class AddSanitaryStatePage extends State<AddSanitaryState> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _correctiveActionController =
      TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  bool _isLoading = false;

  String? _selectedAnimal;
  late Future<List<dynamic>> _animalsList;

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

      Map<String, dynamic> sanitaryStateData = {
        'id': Ulid().toString(),
        'ong_id': prefs['ong_id'],
        'site_id': prefs['site_id'],
        'user_id': prefs['user_id'],
        'animal_id': _selectedAnimal!,
        'label': _labelController.text,
        'description': _descriptionController.text,
        'corrective_action': _correctiveActionController.text,
        'cost': _costController.text,
        'temperature': _temperatureController.text,
        'weight': _weightController.text,
        'is_synced': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      await DatabaseHelper.instance.insertSanitaryState(sanitaryStateData);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal enregistré avec succès !')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SanitaryStatePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un etat sanitaire',
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
                          return 'Veuillez sélectionner un animal';
                        }
                        return null;
                      },
                      label: 'Animal',
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _labelController,
                      labelText: 'Libellé',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un libellé';
                        }
                        if (value.length < 3) {
                          return 'Le nom doit contenir au moins 3 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _descriptionController,
                      labelText: 'Description',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _temperatureController,
                      labelText: 'Température(°C)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _correctiveActionController,
                      labelText: 'Action corrective',
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _costController,
                      labelText: 'Cout(XOF)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _weightController,
                      labelText: 'Poids(kg)',
                      keyboardType: TextInputType.number,
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
