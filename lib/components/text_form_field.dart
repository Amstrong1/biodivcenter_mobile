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
  final bool enabled;

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
    this.enabled = true,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool? _obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(accentColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: widget.controller,
        cursorColor: Color(primaryColor),
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
          border: const UnderlineInputBorder(borderSide: BorderSide.none),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: Color(primaryColor),
                )
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    widget.obscureText
                        ? Icons.visibility_off
                        : Icons.visibility,
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
        enabled: widget.enabled,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }
}
