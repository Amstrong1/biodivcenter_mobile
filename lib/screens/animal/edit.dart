import 'package:biodivcenter/components/circular_progess_indicator.dart';
import 'package:biodivcenter/components/date_field.dart';
import 'package:biodivcenter/components/dropdown_field.dart';
import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/Animal.dart';
import 'package:biodivcenter/screens/animal/index.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';

class EditAnimalPage extends StatefulWidget {
  const EditAnimalPage({super.key, required this.animal});

  final Animal animal;

  @override
  _EditAnimalPageState createState() => _EditAnimalPageState();
}

class _EditAnimalPageState extends State<EditAnimalPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  String? _selectedDate;

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
    final response =
        await http.get(Uri.parse('$apiBaseUrl/api/parents/$specieId'));
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

    _nameController.text = widget.animal.name;
    _weightController.text = widget.animal.weight.toString();
    _heightController.text = widget.animal.height.toString();
    _descriptionController.text = widget.animal.description;
    _originController.text = widget.animal.origin;
    _selectedSex = widget.animal.sex;
    _selectedDate = widget.animal.birthdate;
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
        'PUT',
        Uri.parse('$apiBaseUrl/api/individu/${widget.animal.id}'),
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
      request.fields['birthdate'] = _selectedDate!;
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
          const SnackBar(
            content: Text('Animal enregistré avec succès !'),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AnimalPage()),
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
        title: const Text('Modifier un individu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                CustomDropdown(
                  itemList: _speciesList,
                  selectedItem: _selectedSpecie,
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecie = value;
                      _fetchParents(int.parse(_selectedSpecie!));
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez choisir une espèce';
                    }
                    return null;
                  },
                  label: 'Espèce',
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _weightController,
                  labelText: 'Poids(kg)',
                  keyboardType: TextInputType.number,
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
                  labelText: 'Taille(cm)',
                  keyboardType: TextInputType.number,
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
                CustomDropdown(
                  itemList: _sexOptions,
                  selectedItem: _selectedSex,
                  onChanged: (value) {
                    setState(() {
                      _selectedSex = value;
                    });
                  },
                  label: 'Sexe',
                ),
                const SizedBox(height: 20),
                DatePickerFormField(
                  labelText: 'Date de naissance',
                  selectedDate: _selectedDate,
                  onDateSelected: (selectedDate) {
                    setState(() {
                      _selectedDate = selectedDate;
                    });
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
                CustomDropdown(
                  itemList: _parentList,
                  selectedItem: _selectedParent,
                  onChanged: (value) {
                    setState(() {
                      _selectedParent = value;
                    });
                  },
                  label: 'Parent',
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
                const Text('Photo de l\'animal :'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _selectImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : Image.network(
                            '$apiBaseUrl/storage/${widget.animal.photo!}',
                            fit: BoxFit.cover,
                          ),
                  ),
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
