import 'package:biodivcenter/components/circular_progess_indicator.dart';
import 'package:biodivcenter/components/dropdown_field.dart';
import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/_sanitary_state.dart';
import 'package:biodivcenter/screens/sanitary_state/index.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EditSanitaryState extends StatefulWidget {
  const EditSanitaryState({super.key, required this.sanitaryState});

  final SanitaryState sanitaryState;

  @override
  EditSanitaryStatePage createState() => EditSanitaryStatePage();
}

class EditSanitaryStatePage extends State<EditSanitaryState> {
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

    _labelController.text = widget.sanitaryState.label;
    _descriptionController.text = widget.sanitaryState.description;
    _correctiveActionController.text = widget.sanitaryState.correctiveAction!;
    _costController.text = widget.sanitaryState.cost.toString();
    _temperatureController.text = widget.sanitaryState.temperature.toString();
    _heightController.text = widget.sanitaryState.height != null
        ? widget.sanitaryState.height.toString()
        : "";
    _weightController.text = widget.sanitaryState.weight != null
        ? widget.sanitaryState.weight.toString()
        : "";

    _selectedAnimal = widget.sanitaryState.id.toString();
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
        Uri.parse(
            '$apiBaseUrl/api/api-sanitary-state/${widget.sanitaryState.id}'),
      );
      // request.headers['Authorization'] =
      //     'Bearer ${(await SharedPreferences.getInstance()).getString('token')}';

      request.fields['user_id'] =
          (await SharedPreferences.getInstance()).getInt('id').toString();
      request.fields['animal_id'] = _selectedAnimal!;
      request.fields['label'] = _labelController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['corrective_action'] = _correctiveActionController.text;
      request.fields['cost'] = _costController.text;
      request.fields['temperature'] = _temperatureController.text;
      request.fields['height'] = _heightController.text;
      request.fields['weight'] = _weightController.text;

      final response = await request.send();

      if (response.statusCode == 200) {
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'enregistrement'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
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
                controller: _heightController,
                labelText: 'Taille(cm)',
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
      )),
    );
  }
}
