import 'package:biodivcenter/helpers/global.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final bool readOnly;
  final Function()? onTap;
  final int maxLines;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool? _obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      cursorColor: Color(primaryColor),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(
          textBaseline: TextBaseline.alphabetic,
          fontFamily: 'Poppins',
          color: Colors.black,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Color(accentColor),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: Color(primaryColor),
              )
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  widget.obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Color(primaryColor),
                ),
                onPressed: () {
                  setState(() {
                    if (_obscureText == null) {
                      _obscureText = !widget.obscureText;
                    } else {
                      _obscureText = !_obscureText!;
                    }
                  });
                },
              )
            : null,
      ),
      obscureText: _obscureText ?? widget.obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      maxLines: widget.maxLines,
      style: const TextStyle(
        fontFamily: 'Poppins',
        color: Colors.black,
        fontSize: 12,
      ),
    );
  }
}
