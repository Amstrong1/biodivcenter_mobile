import 'package:biodivcenter/components/dropdown_field.dart';
import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/sanitary_state/index.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  bool _isLoading = false;

  String? _selectedAnimal;
  List<dynamic> _animalsList = [];

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
        Uri.parse('$apiBaseUrl/api/api-sanitary-state'),
      );
      // request.headers['Authorization'] =
      //     'Bearer ${(await SharedPreferences.getInstance()).getString('token')}';

      request.fields['user_id'] =
          (await SharedPreferences.getInstance()).getInt('user_id').toString();
      request.fields['ong_id'] =
          (await SharedPreferences.getInstance()).getInt('ong_id').toString();
      request.fields['site_id'] =
          (await SharedPreferences.getInstance()).getInt('site_id').toString();
      request.fields['animal_id'] = _selectedAnimal!;
      request.fields['label'] = _labelController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['corrective_action'] = _correctiveActionController.text;
      request.fields['cost'] = _costController.text;
      request.fields['temperature'] = _temperatureController.text;
      request.fields['height'] = _heightController.text;
      request.fields['weight'] = _weightController.text;
      request.fields['slug'] = _labelController.text
          .toLowerCase()
          .replaceAll(RegExp(r'\s'), '-')
          .replaceAll(RegExp(r'[^\w-]'), '');
      final response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal enregistré avec succès !')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SanitaryStatePage()),
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
        title: const Text('Ajouter un individu'),
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
                controller: _correctiveActionController,
                labelText: 'Action corrective',
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _costController,
                labelText: 'Cout',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _heightController,
                labelText: 'Taille',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _weightController,
                labelText: 'Poids',
                keyboardType: TextInputType.number,
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
      )),
    );
  }
}
