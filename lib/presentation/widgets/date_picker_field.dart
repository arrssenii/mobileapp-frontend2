import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    required this.label,
    this.initialDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _controller = TextEditingController(
      text: _selectedDate != null 
          ? DateFormat('dd.MM.yyyy').format(_selectedDate!) 
          : '',
    );
  }

  Future<void> _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B8B8B), // Основной цвет
              onPrimary: Colors.white,    // Текст на основном цвете
              surface: Colors.white,      // Фон календаря
              onSurface: Color(0xFF8B8B8B), // Текст в календаре
            ),
            dialogBackgroundColor: Colors.white, // Фон диалога
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B8B8B), // Цвет текста кнопок
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _controller.text = DateFormat('dd.MM.yyyy').format(pickedDate);
      });
      widget.onDateSelected(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: Color(0xFF8B8B8B)),
          onPressed: _showDatePicker,
        ),
      ),
      readOnly: true,
      onTap: _showDatePicker,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}