import 'package:flutter/material.dart';
import 'package:biodivcenter/helpers/global.dart';

class CustomCircularProgessIndicator extends StatelessWidget {
  const CustomCircularProgessIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Color(primaryColor),
        ),
      ),
    );
  }
}
