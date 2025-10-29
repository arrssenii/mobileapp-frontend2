import 'package:flutter/material.dart';

/// Система адаптивного дизайна для приложения
class ResponsiveLayout {
  /// Breakpoints для разных размеров экрана
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Определяет тип устройства на основе ширины экрана
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Возвращает количество колонок для GridView в зависимости от устройства
  static int getGridColumns(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }

  /// Возвращает отступы в зависимости от устройства
  static EdgeInsets getPadding(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  /// Возвращает размер шрифта заголовка в зависимости от устройства
  static double getTitleFontSize(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 20;
      case DeviceType.tablet:
        return 24;
      case DeviceType.desktop:
        return 28;
    }
  }

  /// Возвращает размер шрифта текста в зависимости от устройства
  static double getBodyFontSize(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 14;
      case DeviceType.tablet:
        return 16;
      case DeviceType.desktop:
        return 18;
    }
  }

  /// Возвращает высоту кнопки в зависимости от устройства
  static double getButtonHeight(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 44; // Минимальный размер для доступности
      case DeviceType.tablet:
        return 48;
      case DeviceType.desktop:
        return 52;
    }
  }

  /// Возвращает размер иконки в зависимости от устройства
  static double getIconSize(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 20;
      case DeviceType.tablet:
        return 24;
      case DeviceType.desktop:
        return 28;
    }
  }
}

/// Типы устройств
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Адаптивный контейнер с автоматической настройкой отступов
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? ResponsiveLayout.getPadding(context),
      child: child,
    );
  }
}

/// Адаптивный текст с автоматической настройкой размера
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool isTitle;

  const ResponsiveText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.isTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? const TextStyle();
    final fontSize = isTitle
        ? ResponsiveLayout.getTitleFontSize(context)
        : ResponsiveLayout.getBodyFontSize(context);

    return Text(
      text,
      style: baseStyle.copyWith(fontSize: fontSize),
      textAlign: textAlign,
    );
  }
}

/// Адаптивная кнопка с правильным размером для доступности
class ResponsiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isExpanded;

  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveLayout.getButtonHeight(context);
    final baseStyle = style ?? ElevatedButton.styleFrom();

    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: baseStyle.copyWith(
        minimumSize: MaterialStateProperty.all(
          Size(double.infinity, buttonHeight),
        ),
      ),
      child: child,
    );

    if (isExpanded) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// Адаптивная иконка с правильным размером
class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;

  const ResponsiveIcon({
    super.key,
    required this.icon,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? ResponsiveLayout.getIconSize(context);
    return Icon(
      icon,
      size: iconSize,
      color: color,
    );
  }
}

/// Адаптивный GridView с автоматической настройкой колонок
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: ResponsiveLayout.getGridColumns(context),
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      padding: ResponsiveLayout.getPadding(context),
      children: children,
    );
  }
}