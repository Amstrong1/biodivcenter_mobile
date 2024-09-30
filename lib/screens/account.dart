import 'dart:io';

import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/auth_provider.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/helpers/user_service.dart';
import 'package:biodivcenter/models/_user.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:biodivcenter/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<User> _user;
  final UserService _userService = UserService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  File? _selectedImage;
  final _imagePicker = ImagePicker();

  Future _selectImage() async {
    await requestPermissions();
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await _userService.updateUser(
          name: _nameController.text,
          email: _emailController.text,
          contact: _contactController.text,
          imageFile: _selectedImage,
        );
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response == true
                  ? 'Informations mises à jour.'
                  : 'Une erreur est survenue.',
            ),
          ),
        );
        if (response == true) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AccountPage(),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une erreur est survenue.'),
          ),
        );
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _user = _userService.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: FutureBuilder<User>(
          future: _user,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Erreur : ${snapshot.error}");
            } else if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    "Une erreur est survenue lors de la récupération des informations de l'utilisateur.",
                  ),
                ],
              );
            } else {
              final user = snapshot.data!; // Accéder à l'utilisateur récupéré
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Compte',
                                style: TextStyle(
                                  fontFamily: 'Merriweather',
                                  color: Color(primaryColor),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _isEditing = !_isEditing;
                                          if (_isEditing == false) {
                                            _submitForm();
                                          }
                                        });
                                      },
                                      label: Text(
                                        _isEditing ? "Enregistrer" : "Editer",
                                        style: TextStyle(
                                          color: _isEditing
                                              ? Color(primaryColor)
                                              : Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isEditing
                                            ? Color(secondaryColor)
                                            : Colors.amber[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                              if (_isEditing)
                                Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isEditing = !_isEditing;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      child: const Text(
                                        "Annuler",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _isEditing
                          ? _buildImagePicker(user.picture)
                          : Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: user.picture != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          '$apiBaseUrl/storage/${user.picture}',
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: user.picture == null
                                  ? Center(
                                      child: Text(
                                        user.name[0], // Utilisation du snapshot
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Color(primaryColor),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: _nameController..text = user.name,
                        labelText: 'Nom',
                        prefixIcon: Icons.person_outlined,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: _organizationController..text = user.ong,
                        labelText: 'Organisation',
                        prefixIcon: Icons.business_center_outlined,
                        enabled: false,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: _countryController..text = user.country,
                        labelText: 'Pays',
                        prefixIcon: Icons.location_on_outlined,
                        enabled: false,
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: _emailController..text = user.email,
                        labelText: 'Email',
                        prefixIcon: Icons.email_outlined,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: _contactController..text = user.contact,
                        labelText: 'Contact',
                        prefixIcon: Icons.phone_outlined,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre contact';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Modifier le mot de passe',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await context.read<AuthProvider>().logout();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Se deconnecter',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  _buildImagePicker(userPicture) {
    return GestureDetector(
      onTap: _selectImage,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
          image: DecorationImage(
            image: _selectedImage != null
                ? Image.file(_selectedImage!).image
                : NetworkImage(
                    '$apiBaseUrl/storage/$userPicture',
                  ),
            fit: BoxFit.cover,
          ),
        ),
        width: 100,
        height: 100,
      ),
    );
  }
}
