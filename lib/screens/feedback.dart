import 'package:biodivcenter/components/text_form_field.dart';
import 'package:biodivcenter/helpers/global.dart';
import 'package:biodivcenter/screens/base.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feedback',
                              style: TextStyle(
                                fontFamily: 'Merriweather',
                                color: Color(primaryColor),
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nous apprécions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'votre retour.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Nous recherchons toujours des moyens de améliorer votre expérience. '
                      'Veuillez prendre un moment pour évaluer et dites-nous ce que vous en pensez.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Que pouvons-nous faire pour améliorer votre expérience?',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      maxLines: 5,
                      controller: _textEditingController,
                      labelText: 'Écrivez ici...',
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Envoyer',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
