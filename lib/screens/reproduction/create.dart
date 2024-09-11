import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AddReproductionPage extends StatefulWidget {
  const AddReproductionPage({super.key});

  @override
  _AddReproductionPageState createState() => _AddReproductionPageState();
}

class _AddReproductionPageState extends State<AddReproductionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phaseController = TextEditingController();
  final TextEditingController _litterSizeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _observationController = TextEditingController();

  bool _isLoading = false;

  String? _selectedAnimal;
  List<dynamic> _animalsList = [];

  String? _selectedPhase;
  final List<String> _phaseOptions = [
    'Ponte',
    'Eclosion',
    'Mise bas',
  ];

  // Fonction pour récupérer la liste des espèces depuis l'API
  Future<void> _fetchAnimals() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/animals-list'));
    if (response.statusCode == 200) {
      setState(() {
        _animalsList = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
  }

  /// Function to send the animal creation form to the API and handle
  /// validation and sending errors. Displays a success or error message
  /// depending on the sending status.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/api/api-reproduction'),
      );
      // request.headers['Authorization'] =
      //     'Bearer ${(await SharedPreferences.getInstance()).getString('token')}';

      request.fields['ong_id'] =
          (await SharedPreferences.getInstance()).getInt('ong_id').toString();
      request.fields['site_id'] =
          (await SharedPreferences.getInstance()).getInt('site_id').toString();
      request.fields['animal_id'] = _selectedAnimal!;
      request.fields['phase'] = _phaseController.text;
      request.fields['litter_size'] = _litterSizeController.text;
      request.fields['date'] = _dateController.text;
      request.fields['observation'] = _observationController.text;
      request.fields['slug'] = '';

      final response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reproduction enregistré avec succès !')),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'enregistrement')),
        );
      }
    }
  }

  /// Clears all the form fields and reset the selected values
  /// to `null`. This is used when the form is submitted and
  /// the user wants to enter a new animal.
  void _clearForm() {
    _phaseController.clear();
    _litterSizeController.clear();
    _dateController.clear();
    _observationController.clear();
    setState(() {
      _selectedAnimal = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une reproduction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Animal'),
                  value: _selectedAnimal,
                  items: _animalsList.map<DropdownMenuItem<String>>((animal) {
                    return DropdownMenuItem<String>(
                      value: animal['id'].toString(),
                      child: Text(animal['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAnimal = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner une espèce';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Phase'),
                  value: _selectedPhase,
                  items: _phaseOptions.map<DropdownMenuItem<String>>((phase) {
                    return DropdownMenuItem<String>(
                      value: phase,
                      child: Text(phase),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPhase = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner une phase';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _litterSizeController,
                  labelText: 'Portée',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une portée';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Taille invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _dateController,
                  labelText: 'Date',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _observationController,
                  labelText: 'Observation',
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Enregistrer'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
