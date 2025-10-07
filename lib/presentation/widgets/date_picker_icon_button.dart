import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class DatePickerIconButton extends StatelessWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final IconData icon;
  final Color? iconColor;
  final String? tooltip;
  final bool showDateText;

  const DatePickerIconButton({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.icon = Icons.calendar_today,
    this.iconColor,
    this.tooltip,
    this.showDateText = false,
  });

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
        if (showDateText && initialDate != null)
          Text(
            DateFormat('dd.MM.yyyy').format(initialDate!),
            style: const TextStyle(fontSize: 16),
          ),
      ],
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      locale: const Locale('ru', 'RU'), // Русская локаль
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('ru', 'RU'),
          delegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          child: Theme(
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
          ),
        );
      },
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }
}