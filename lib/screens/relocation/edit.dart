import 'package:biodivcenter/components/date_field.dart';
import 'package:biodivcenter/components/dropdown_field.dart';
import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/models/_relocation.dart';
import 'package:biodivcenter/screens/relocation/index.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EditRelocationPage extends StatefulWidget {
  const EditRelocationPage({super.key, required this.relocation});

  final Relocation relocation;

  @override
  _EditRelocationPageState createState() => _EditRelocationPageState();
}

class _EditRelocationPageState extends State<EditRelocationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  String? _selectedDate;

  bool _isLoading = false;

  String? _selectedAnimal;
  List<dynamic> _animalsList = [];

  String? _selectedPenOrigin;
  String? _selectedPenDestination;
  List<dynamic> _pensList = [];

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

  // Fonction pour récupérer la liste des enclos depuis l'API
  Future<void> _fetchPens() async {
    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/api/pens-list/${(await SharedPreferences.getInstance()).getInt('site_id')!}',
      ),
    );
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

    _commentController.text = widget.relocation.comment!;
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
        Uri.parse('$apiBaseUrl/api/api-relocation/${widget.relocation.id}'),
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
      request.fields['date_transfert'] = _selectedDate!;

      final response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfert enregistré avec succès !')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RelocationPage()),
        );
      } else {
        print(response);
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
          'Ajouter un transfert',
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
                CustomDropdown(
                  itemList: _pensList,
                  selectedItem: _selectedPenOrigin,
                  onChanged: (value) {
                    setState(() {
                      _selectedPenOrigin = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un enclos';
                    }
                    return null;
                  },
                  label: 'Enclos destination',
                ),
                const SizedBox(height: 20),
                CustomDropdown(
                  itemList: _pensList,
                  selectedItem: _selectedPenDestination,
                  onChanged: (value) {
                    setState(() {
                      _selectedPenDestination = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un enclos';
                    }
                    return null;
                  },
                  label: 'Enclos origine',
                ),
                const SizedBox(height: 20),
                DatePickerFormField(
                  labelText: 'Date de transfert',
                  onDateSelected: (selectedDate) {
                    setState(() {
                      _selectedDate = selectedDate;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _commentController,
                  labelText: 'Commentaire',
                  maxLines: 8,
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
      ),
    );
  }
}
