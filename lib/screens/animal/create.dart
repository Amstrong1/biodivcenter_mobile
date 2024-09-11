import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AddAnimalPage extends StatefulWidget {
  const AddAnimalPage({super.key});

  @override
  _AddAnimalPageState createState() => _AddAnimalPageState();
}

class _AddAnimalPageState extends State<AddAnimalPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  final TextEditingController _originController = TextEditingController();

  bool _isLoading = false;

  String? _selectedSpecie;
  List<dynamic> _speciesList = [];

  String? _selectedParent;
  List<dynamic> _parentList = [];

  String? _selectedSex;
  final List<String> _sexOptions = ['Mâle', 'Femelle'];

  File? _selectedImage;
  final _imagePicker = ImagePicker();

  // Fonction pour récupérer la liste des espèces depuis l'API
  Future<void> _fetchSpecies() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/species-list'));
    if (response.statusCode == 200) {
      setState(() {
        _speciesList = jsonDecode(response.body);
      });
    }
  }

  // Fonction pour récupérer la liste des parents d'une espèce sélectionnée
  Future<void> _fetchParents(int specieId) async {
    final response = await http
        .get(Uri.parse('$apiBaseUrl/api/animals-list/specie_id=$specieId'));
    if (response.statusCode == 200) {
      setState(() {
        _parentList = jsonDecode(response.body);
      });
    }
  }

  Future _selectImage() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
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
        Uri.parse('$apiBaseUrl/api/individu'),
      );
      // request.headers['Authorization'] =
      //     'Bearer ${(await SharedPreferences.getInstance()).getString('token')}';

      request.fields['ong_id'] =
          (await SharedPreferences.getInstance()).getInt('ong_id').toString();
      request.fields['site_id'] =
          (await SharedPreferences.getInstance()).getInt('site_id').toString();
      request.fields['name'] = _nameController.text;
      request.fields['specie_id'] = _selectedSpecie!;
      request.fields['weight'] = _weightController.text;
      request.fields['height'] = _heightController.text;
      request.fields['sex'] = _selectedSex!;
      request.fields['birthdate'] = _birthdateController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['origin'] = _originController.text;
      request.fields['slug'] = _nameController.text
          .toLowerCase()
          .replaceAll(RegExp(r'\s'), '-')
          .replaceAll(RegExp(r'[^\w-]'), '');
      // request.fields['parent_id'] = _selectedParent!;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          _selectedImage!.path,
        ));
      }

      final response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal enregistré avec succès !')),
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
    _nameController.clear();
    _weightController.clear();
    _heightController.clear();
    _birthdateController.clear();
    _descriptionController.clear();
    _photoController.clear();
    _originController.clear();
    setState(() {
      _selectedSpecie = null;
      _selectedParent = null;
      _selectedSex = null;
    });
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
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Nom de l\'animal',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  if (value.length < 3) {
                    return 'Le nom doit contenir au moins 3 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Espèce'),
                value: _selectedSpecie,
                items: _speciesList.map<DropdownMenuItem<String>>((specie) {
                  return DropdownMenuItem<String>(
                    value: specie['id'].toString(),
                    child: Text(specie['french_name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecie = value;
                    _fetchParents(
                      int.parse(value!),
                    );
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
              CustomTextFormField(
                controller: _weightController,
                labelText: 'Poids',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un poids';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Poids invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _heightController,
                labelText: 'Taille',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une taille';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Taille invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sexe'),
                value: _selectedSex,
                items: _sexOptions.map<DropdownMenuItem<String>>((sex) {
                  return DropdownMenuItem<String>(
                    value: sex,
                    child: Text(sex),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSex = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner le sexe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _birthdateController,
                labelText: 'Date de naissance',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une date de naissance';
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
                  if (value.length < 3) {
                    return 'La description doit contenir au moins 3 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Parent'),
                value: _selectedParent,
                items: _parentList.map<DropdownMenuItem<String>>((parent) {
                  return DropdownMenuItem<String>(
                    value: parent['id'].toString(),
                    child: Text(parent['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedParent = value;
                  });
                },
                // validator: (value) {
                //   if (value == null) {
                //     return 'Veuillez sélectionner un parent';
                //   }
                //   return null;
                // },
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _originController,
                labelText: 'Origine',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une origine';
                  }
                  if (value.length < 3) {
                    return 'L\'origine doit contenir au moins 3 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _selectImage,
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[200],
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : const Icon(Icons.add_a_photo, size: 50),
                ),
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
