import 'package:flutter/material.dart';
import '../../presentation/widgets/design_system/input_fields.dart';

class AppTheme {
  // Основные цвета
  static const Color primaryColor = Color(0xFF5F9EA0);
  static const Color secondaryColor = Color(0xFF4682B4);
  static const Color accentColor = Color(0xFF90A4AE); // Серо-голубой вместо бежевого
  static const Color backgroundColor = Color(0xFFF8F9FA); // Светло-серый фон
  static const Color scaffoldBackgroundColor = Color(0xFFF8F9FA); // Светло-серый фон
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF8B8B8B);
  static const Color textLight = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFFA000);

  // Цвета для статусов
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusScheduled = Color(0xFF2196F3);
  static const Color statusNoShow = Color(0xFFF44336);
  static const Color statusEmergency = Color(0xFFFF5722);
  static const Color statusUrgent = Color(0xFFFF9800);

  // Основная тема приложения
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      
      // Основные цвета
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      cardColor: cardColor,
      canvasColor: backgroundColor,

      // AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 1,
        backgroundColor: primaryColor,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        iconTheme: IconThemeData(color: textLight),
      ),

      // Поля ввода
      inputDecorationTheme: AppInputTheme.inputDecorationTheme,

      // Кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          textStyle: const TextStyle(fontSize: 18),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),

      // Нижняя навигация
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),

      // Карточки
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Методы для получения цветов статусов
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'завершён':
        return statusCompleted;
      case 'scheduled':
      case 'запланирован':
        return statusScheduled;
      case 'no_show':
      case 'отменён':
        return statusNoShow;
      case 'emergency':
      case 'экстренный':
        return statusEmergency;
      case 'urgent':
      case 'неотложный':
        return statusUrgent;
      default:
        return statusScheduled;
    }
  }
}

// Расширение для удобного использования цветов темы
extension ThemeExtension on BuildContext {
  Color get primaryColor => AppTheme.primaryColor;
  Color get secondaryColor => AppTheme.secondaryColor;
  Color get accentColor => AppTheme.accentColor;
  Color get backgroundColor => AppTheme.backgroundColor;
  Color get textPrimary => AppTheme.textPrimary;
  Color get textSecondary => AppTheme.textSecondary;
  Color get textLight => AppTheme.textLight;
  Color get errorColor => AppTheme.errorColor;
  Color get successColor => AppTheme.successColor;
  Color get warningColor => AppTheme.warningColor;

  Color getStatusColor(String status) => AppTheme.getStatusColor(status);
}