import 'dart:io';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:biodivcenter/components/date_field.dart';
import 'package:biodivcenter/components/dropdown_field.dart';
import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/animal/index.dart';
import 'package:ulid/ulid.dart';

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
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  String? _selectedDate;

  bool _isLoading = false;

  String? _selectedSpecie;
  String? _selectedParent;
  String? _selectedSex;
  String? _fileError;

  late Future<List<dynamic>> _speciesList;
  final List<String> _sexOptions = ['Mâle', 'Femelle'];
  late Future<List<dynamic>> _parentList = Future.value([]);

  File? _selectedImage;
  final _imagePicker = ImagePicker();

  Future _selectImage() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _showImageSourceSelector(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir dans la galerie'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selectImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getLocalSpecies() async {
    setState(() {
      _speciesList = DatabaseHelper.instance.getSpecies();
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      if (_selectedImage != null) {
        Map<String, dynamic> prefs = await getSharedPrefs();

        Map<String, dynamic> animalData = {
          'id': Ulid().toString(),
          'ong_id': prefs['ong_id'],
          'site_id': prefs['site_id'],
          'name': _nameController.text,
          'specie_id': _selectedSpecie!,
          'weight': _weightController.text,
          'height': _heightController.text,
          'sex': _selectedSex!,
          'birthdate': _selectedDate!,
          'description': _descriptionController.text,
          'origin': _originController.text,
          'parent_id': _selectedParent,
          'is_synced': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        File savedImage = await saveImageLocally(_selectedImage!);
        animalData = {...animalData, 'photo': savedImage.path};

        await DatabaseHelper.instance.insertAnimal(animalData);

        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AnimalPage()),
        );
      } else {
        setState(() {
          _fileError = 'Sélectionner une image';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _getLocalSpecies(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un individu',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _speciesList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune espèce trouvée.'));
          }

          List<dynamic> speciesList = snapshot.data!;
          return SingleChildScrollView(
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
                      itemList: speciesList,
                      selectedItem: _selectedSpecie,
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecie = value;
                          _parentList = DatabaseHelper.instance.getParents(
                            value!,
                          );
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez choisir le sexe';
                        }
                        return null;
                      },
                      label: 'Sexe',
                    ),
                    const SizedBox(height: 20),
                    DatePickerFormField(
                      labelText: 'Date de naissance',
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
                    FutureBuilder<List<dynamic>>(
                      future: _parentList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Erreur : ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(accentColor),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 18.0,
                              horizontal: 12,
                            ),
                            child: const Text(
                              'Aucun parent trouvé',
                              style: TextStyle(
                                fontSize: 10.0,
                              ),
                            ),
                          );
                        }

                        return CustomDropdown(
                          itemList: snapshot.data!,
                          selectedItem: _selectedParent,
                          onChanged: (value) {
                            setState(() {
                              _selectedParent = value;
                            });
                          },
                          label: 'Parent',
                        );
                      },
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
                      onTap: () => _showImageSourceSelector(context),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : const Icon(Icons.add_a_photo, size: 50),
                      ),
                    ),
                    Text(
                      _fileError ?? '',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
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
