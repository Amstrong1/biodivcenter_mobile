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

  /// Retourne un DropdownButtonFormField qui permet à l'utilisateur de choisir
  /// un item dans une liste. La liste est fournie par le paramètre itemList.
  ///
  /// Si la liste est vide, le champ est gris  et ne peut pas être modifié.
  /// Si la liste n'est pas vide et que le paramètre selectedItem n'est pas
  /// fourni, le premier item de la liste est selectionné par defaut.
  ///
  /// Le texte de chaque item est détermin  de la façon suivante :
  /// - Si l'item est un String, le texte est ce String.
  /// - Si l'item est un Map, le texte est la valeur de la clé  'french_name'
  ///   si elle existe, sinon la valeur de la clé  'name' si elle existe,
  ///   sinon la représentation en String de l'item.
  ///
  /// Le champ peut  tre validé  grace au paramètre validator qui est appelé
  /// lorsqu'un item est sélectionn . Si le paramètre validator n'est pas
  /// fourni, la validation est inexistante.
  ///
  /// Lorsqu'un item est sélectionn , le paramètre onChanged est appelé avec
  /// l'item sélectionné comme argument.
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(accentColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 12,
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
