import 'package:biodivcenter/helpers/global.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final List<dynamic> itemList;
  final String? selectedItem;
  final Function(String?) onChanged;
  final String label;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    required this.itemList,
    required this.selectedItem,
    required this.onChanged,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
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
      ),
      value: selectedItem,
      items: itemList.map<DropdownMenuItem<String>>((item) {
        return DropdownMenuItem<String>(
          value: item is String ? item : item['id'].toString(),
          child: Text(
            item is String
                ? item
                : item.containsKey('french_name')
                    ? item['french_name']
                    : item.containsKey('name')
                        ? item['name']
                        : item.toString(),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Poppins',
        color: Colors.black,
        fontSize: 12,
      ),
    );
  }
}
