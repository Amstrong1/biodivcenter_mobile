import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AddRelocationPage extends StatefulWidget {
  const AddRelocationPage({super.key});

  @override
  _AddRelocationPageState createState() => _AddRelocationPageState();
}

class _AddRelocationPageState extends State<AddRelocationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _dateTransfertController =
      TextEditingController();

  bool _isLoading = false;

  String? _selectedAnimal;
  List<dynamic> _animalsList = [];

  String? _selectedPenOrigin;
  String? _selectedPenDestination;
  List<dynamic> _pensList = [];

  // Fonction pour récupérer la liste des espèces depuis l'API
  Future<void> _fetchAnimals() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/animals-list'));
    if (response.statusCode == 200) {
      setState(() {
        _animalsList = jsonDecode(response.body);
      });
    }
  }

  // Fonction pour récupérer la liste des enclos depuis l'API
  Future<void> _fetchPens() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/pens-list'));
    if (response.statusCode == 200) {
      setState(() {
        _pensList = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
    _fetchPens();
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
        Uri.parse('$apiBaseUrl/api/api-relocation'),
      );
      // request.headers['Authorization'] =
      //     'Bearer ${(await SharedPreferences.getInstance()).getString('token')}';

      request.fields['user_id'] =
          (await SharedPreferences.getInstance()).getInt('user_id').toString();
      request.fields['animal_id'] = _selectedAnimal!;
      request.fields['ong_origin_id'] =
          (await SharedPreferences.getInstance()).getInt('ong_id').toString();
      request.fields['ong_destination_id'] =
          (await SharedPreferences.getInstance()).getInt('ong_id').toString();
      request.fields['site_origin_id'] =
          (await SharedPreferences.getInstance()).getInt('site_id').toString();
      request.fields['site_destination_id'] =
          (await SharedPreferences.getInstance()).getInt('site_id').toString();
      request.fields['pen_origin_id'] = _selectedPenOrigin!;
      request.fields['pen_destination_id'] = _selectedPenDestination!;
      request.fields['comment'] = _commentController.text;
      request.fields['date_transfert'] = _dateTransfertController.text;
      request.fields['slug'] = '';

      final response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfert enregistré avec succès !')),
        );
        _clearForm();
      } else {
        print(response);
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
    _commentController.clear();
    _dateTransfertController.clear();
    setState(() {
      _selectedAnimal = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un transfert'),
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
                    return 'Veuillez sélectionner un animal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Animal'),
                value: _selectedPenOrigin,
                items: _pensList.map<DropdownMenuItem<String>>((penOrigin) {
                  return DropdownMenuItem<String>(
                    value: penOrigin['id'].toString(),
                    child: Text(penOrigin['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPenOrigin = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un enclos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Animal'),
                value: _selectedPenDestination,
                items: _pensList.map<DropdownMenuItem<String>>((penDestination) {
                  return DropdownMenuItem<String>(
                    value: penDestination['id'].toString(),
                    child: Text(penDestination['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPenDestination = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un enclos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _dateTransfertController,
                labelText: 'Date',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _commentController,
                labelText: 'Commentaire',
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
