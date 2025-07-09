import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerIconButton extends StatelessWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final IconData icon;
  final Color? iconColor;
  final String? tooltip;
  final bool showSelectedDate;

  const DatePickerIconButton({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.icon = Icons.calendar_today,
    this.iconColor,
    this.tooltip,
    this.showSelectedDate = false,
  });

  Future<void> _showDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B8B8B),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF8B8B8B),
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B8B8B),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: iconColor ?? const Color(0xFF8B8B8B)),
          onPressed: () => _showDatePicker(context),
          tooltip: tooltip ?? 'Выбрать дату',
        ),
        if (showSelectedDate && initialDate != null)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              DateFormat('dd.MM.yyyy').format(initialDate!),
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }
}