import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String text;
  final bool isEmergency;

  const StatusChip({
    super.key,
    required this.text,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isEmergency 
              ? Colors.red.shade800 
              : Theme.of(context).primaryColor,
        ),
      ),
      backgroundColor: isEmergency 
          ? Colors.red.shade50 
          : Colors.grey.shade200,
    );
  }
}