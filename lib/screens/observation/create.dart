import 'dart:io';

import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/database_helper.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/observation/index.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddObservationPage extends StatefulWidget {
  const AddObservationPage({super.key});

  @override
  _AddObservationPageState createState() => _AddObservationPageState();
}

class _AddObservationPageState extends State<AddObservationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _observationController = TextEditingController();

  bool _isLoading = false;

  File? _selectedImage;
  final _imagePicker = ImagePicker();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> prefs = await getSharedPrefs();

      Map<String, dynamic> observationData = {
        'ong_id': prefs['ong_id'],
        'site_id': prefs['site_id'],
        'subject': _subjectController.text,
        'observation': _observationController.text,
        'photo': _selectedImage?.path,
        'slug': _subjectController.text
            .toLowerCase()
            .replaceAll(RegExp(r'\s'), '-')
            .replaceAll(RegExp(r'[^\w-]'), ''),
        'is_synced': false, // L'animal n'est pas encore synchronisé avec l'API
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (_selectedImage != null) {
        File savedImage = await saveImageLocally(_selectedImage!);
        observationData = {...observationData, 'photo': savedImage.path};
      }

      await DatabaseHelper.instance.insertObservation(observationData);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Observation enregistrée avec succès !'),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ObservationPage()),
      );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter une observation',
          style: TextStyle(fontSize: 16),
        ),
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
                  controller: _subjectController,
                  labelText: 'Objet',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un objet';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _observationController,
                  labelText: 'Observation',
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un l\'observation';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Image :'),
                const SizedBox(height: 10),
                buildImagePicker(_selectImage, _selectedImage),
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
      ),
    );
  }
}
