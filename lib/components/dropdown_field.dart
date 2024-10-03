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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(accentColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 13,
          ),
          border: const UnderlineInputBorder(borderSide: BorderSide.none),
        ),
        value: selectedItem,
        items: itemList.isNotEmpty
            ? itemList.map<DropdownMenuItem<String>>((item) {
                String avValue;
                String displayName;

                if (item is Map) {
                  avValue = item['id'].toString();
                  displayName = item['french_name'] ?? item['name'];
                } else if (item is String) {
                  avValue = item;
                  displayName = item;
                } else {
                  avValue = item.toString();
                  displayName = item.toString();
                }

                return DropdownMenuItem<String>(
                  value: avValue,
                  child: Text(displayName),
                );
              }).toList()
            : [],
        onChanged: onChanged,
        validator: validator,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }
}
