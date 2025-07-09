import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final int? maxLength;
  final int maxLines;
  final TextInputType keyboardType;
  
  const CustomFormField({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        maxLength: maxLength,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Обязательное поле';
          }
          return null;
        },
      ),
    );
  }
}