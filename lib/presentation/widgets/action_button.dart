import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return isPrimary
        ? ElevatedButton.icon(
            icon: Icon(icon, size: 18),
            label: Text(label),
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B8B8B),
            ),
          )
        : OutlinedButton.icon(
            icon: Icon(icon, size: 18),
            label: Text(label),
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
          );
  }
}