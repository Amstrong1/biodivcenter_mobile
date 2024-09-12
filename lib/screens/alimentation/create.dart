import 'package:biodivcenter/components/circular_progess_indicator.dart';
import 'package:biodivcenter/components/dropdown_field.dart';
import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/alimentation/index.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
  List<dynamic> _speciesList = [];

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

  // Fonction pour récupérer la liste des espèces depuis l'API
  Future<void> _fetchSpecies() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/species-list'));
    if (response.statusCode == 200) {
      setState(() {
        _speciesList = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSpecies();
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
        Uri.parse('$apiBaseUrl/api/api-alimentation'),
      );
      // request.headers['Authorization'] =
      //     'Bearer ${(await SharedPreferences.getInstance()).getString('token')}';

      request.fields['ong_id'] =
          (await SharedPreferences.getInstance()).getInt('ong_id').toString();
      request.fields['site_id'] =
          (await SharedPreferences.getInstance()).getInt('site_id').toString();
      request.fields['user_id'] =
          (await SharedPreferences.getInstance()).getInt('id').toString();
      request.fields['specie_id'] = _selectedSpecie!;
      request.fields['age_range'] = _selectedAge!;
      request.fields['food'] = _foodController.text;
      request.fields['frequency'] = _selectedPeriod!;
      request.fields['quantity'] = _quantityController.text;
      request.fields['cost'] = _costController.text;
      request.fields['slug'] = _foodController.text
          .toLowerCase()
          .replaceAll(RegExp(r'\s'), '-')
          .replaceAll(RegExp(r'[^\w-]'), '');

      final response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alimentation enregistré avec succès !'),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AlimentationPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'enregistrement')),
        );
      }
    }
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
      body: SingleChildScrollView(
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
                  itemList: _speciesList,
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
