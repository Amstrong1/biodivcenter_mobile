import 'package:biodivcenter/components/text_form_field.dart';
import 'package:flutter/material.dart';

class DatePickerFormField extends StatefulWidget {
  final String labelText;
  final Function(String) onDateSelected;
  final String? selectedDate;

  const DatePickerFormField({
    super.key,
    required this.labelText,
    required this.onDateSelected,
    this.selectedDate,
  });

  @override
  _DatePickerFormFieldState createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends State<DatePickerFormField> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  // Fonction pour afficher le sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
        widget.onDateSelected(_dateController.text);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectedDate != null) {
      _selectedDate = DateTime.parse(widget.selectedDate!);
      _dateController.text = "${_selectedDate!.toLocal()}".split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: _dateController,
      labelText: widget.labelText,
      readOnly: true,
      onTap: () {
        _selectDate(context);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une date';
        }
        return null;
      },
    );
  }
}
