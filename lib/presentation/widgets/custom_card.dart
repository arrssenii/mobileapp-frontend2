import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;

  const CustomCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Material( // <-- Добавлено
      type: MaterialType.transparency,
      child: Card(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: backgroundColor ?? Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}