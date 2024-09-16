import 'package:biodivcenter/components/circular_progess_indicator.dart';
import 'package:biodivcenter/components/date_field.dart';
import 'package:biodivcenter/components/dropdown_field.dart';
import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/_reproduction.dart';
import 'package:biodivcenter/screens/reproduction/index.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EditReproductionPage extends StatefulWidget {
  const EditReproductionPage({super.key, required this.reproduction});

  final Reproduction reproduction;

  @override
  _EditReproductionPageState createState() => _EditReproductionPageState();
}

class _EditReproductionPageState extends State<EditReproductionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _litterSizeController = TextEditingController();
  final TextEditingController _observationController = TextEditingController();
  String? _selectedDate;

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
    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/api/individus/${(await SharedPreferences.getInstance()).getInt('site_id')!}',
      ),
    );
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

    _litterSizeController.text = widget.reproduction.litterSize.toString();
    _observationController.text = widget.reproduction.observation!;
    _selectedDate = widget.reproduction.date;
    _selectedPhase = widget.reproduction.phase;
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
        Uri.parse('$apiBaseUrl/api/api-reproduction/${widget.reproduction.id}'),
      );
      // request.headers['Authorization'] =
      //     'Bearer ${(await SharedPreferences.getInstance()).getString('token')}';

      request.fields['animal_id'] = _selectedAnimal!;
      request.fields['phase'] = _selectedPhase!;
      request.fields['litter_size'] = _litterSizeController.text;
      request.fields['date'] = _selectedDate!;
      request.fields['observation'] = _observationController.text;

      final response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reproduction enregistré avec succès !'),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ReproductionPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'enregistrement'),
          ),
        );
      }
    }
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
                CustomDropdown(
                  itemList: _animalsList,
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
                    ? const CustomCircularProgessIndicator()
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
      ),
    );
  }
}
