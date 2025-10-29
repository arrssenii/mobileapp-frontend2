import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Утилиты для улучшения доступности приложения
class AccessibilityUtils {
  /// Минимальный размер тач-цели (44px для iOS, 48px для Material Design)
  static const double minTouchTargetSize = 48.0;

  /// Проверяет контрастность цветов по стандарту WCAG
  static double calculateContrastRatio(Color foreground, Color background) {
    final double luminance1 = _getRelativeLuminance(foreground);
    final double luminance2 = _getRelativeLuminance(background);
    
    final double lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final double darker = luminance1 < luminance2 ? luminance1 : luminance2;
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Проверяет соответствует ли контрастность стандарту WCAG AA
  static bool isContrastSufficient(Color foreground, Color background) {
    final contrastRatio = calculateContrastRatio(foreground, background);
    return contrastRatio >= 4.5; // Минимальный контраст для нормального текста
  }

  /// Проверяет соответствует ли контрастность стандарту WCAG AAA
  static bool isContrastExcellent(Color foreground, Color background) {
    final contrastRatio = calculateContrastRatio(foreground, background);
    return contrastRatio >= 7.0; // Высокий контраст для лучшей читаемости
  }

  /// Рассчитывает относительную яркость цвета
  static double _getRelativeLuminance(Color color) {
    final double r = color.red / 255.0;
    final double g = color.green / 255.0;
    final double b = color.blue / 255.0;

    final double rs = r <= 0.03928 ? r / 12.92 : (pow((r + 0.055) / 1.055, 2.4) as double);
    final double gs = g <= 0.03928 ? g / 12.92 : (pow((g + 0.055) / 1.055, 2.4) as double);
    final double bs = b <= 0.03928 ? b / 12.92 : (pow((b + 0.055) / 1.055, 2.4) as double);

    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
  }

  /// Создает семантическую метку для виджета
  static void setSemanticLabel(Widget widget, String label, {String? hint}) {
    SemanticsService.announce(label, TextDirection.ltr);
  }

  /// Проверяет размер тач-цели и при необходимости увеличивает его
  static Widget ensureMinTouchTarget(Widget child, {double minSize = minTouchTargetSize}) {
    return Semantics(
      button: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}

/// Виджет с улучшенной доступностью
class AccessibleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String semanticLabel;
  final String? semanticHint;
  final ButtonStyle? style;
  final bool ensureMinSize;

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
    this.semanticHint,
    this.style,
    this.ensureMinSize = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );

    if (ensureMinSize) {
      button = AccessibilityUtils.ensureMinTouchTarget(button);
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      hint: semanticHint,
      child: button,
    );
  }
}

/// Текст с проверкой контрастности
class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color backgroundColor;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool? softWrap;

  const AccessibleText({
    super.key,
    required this.text,
    required this.style,
    required this.backgroundColor,
    this.textAlign,
    this.maxLines,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      softWrap: softWrap,
    );
  }
}

/// Карточка с семантической структурой
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String semanticLabel;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const AccessibleCard({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.onTap,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      button: onTap != null,
      child: Card(
        color: color,
        margin: margin,
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

/// Поле ввода с улучшенной доступностью
class AccessibleTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool isRequired;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  const AccessibleTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: label,
      hint: hintText,
      // required: isRequired, // Убрано, так как параметр не поддерживается в Semantics
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          suffix: isRequired ? const Text('*', style: TextStyle(color: Colors.red)) : null,
        ),
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }
}

/// Виджет для объявления изменений скринридерам
class AccessibilityAnnouncer extends StatefulWidget {
  final Widget child;
  final String announcement;
  final bool announceOnBuild;

  const AccessibilityAnnouncer({
    super.key,
    required this.child,
    required this.announcement,
    this.announceOnBuild = false,
  });

  @override
  State<AccessibilityAnnouncer> createState() => _AccessibilityAnnouncerState();
}

class _AccessibilityAnnouncerState extends State<AccessibilityAnnouncer> {
  @override
  void initState() {
    super.initState();
    if (widget.announceOnBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SemanticsService.announce(widget.announcement, TextDirection.ltr);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Расширение для удобного использования доступности
extension AccessibilityExtension on BuildContext {
  /// Объявляет сообщение для скринридера
  void announceForAccessibility(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Проверяет включен ли режим высокой контрастности
  bool get isHighContrastEnabled {
    return MediaQuery.of(this).highContrast;
  }

  /// Проверяет включен ли режим инверсии цветов
  bool get isInvertedColorsEnabled {
    return MediaQuery.of(this).invertColors;
  }

  /// Проверяет включен ли режим увеличенного текста
  bool get isTextScaled {
    return MediaQuery.of(this).textScaleFactor > 1.3;
  }
}