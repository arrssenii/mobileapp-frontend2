import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme_config.dart';

/// Дизайн-система для полей ввода приложения
class AppInputTheme {
  /// Основные цвета для состояний полей ввода
  static const Color primaryColor = AppTheme.primaryColor;
  static const Color secondaryColor = AppTheme.secondaryColor;
  static const Color backgroundColor = AppTheme.backgroundColor;
  static const Color errorColor = AppTheme.errorColor;
  static const Color successColor = AppTheme.successColor;
  static const Color textPrimary = AppTheme.textPrimary;
  static const Color textSecondary = AppTheme.textSecondary;
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color disabledColor = Color(0xFFF5F5F5);

  /// Текстовые стили
  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle hintStyle = TextStyle(
    fontSize: 16,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle inputStyle = TextStyle(
    fontSize: 16,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle errorStyle = TextStyle(
    fontSize: 12,
    color: errorColor,
    height: 1.2,
  );

  /// Стили для полей ввода
  static InputDecorationTheme get inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: disabledColor, width: 1.5),
      ),
      labelStyle: labelStyle,
      hintStyle: hintStyle,
      errorStyle: errorStyle,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      floatingLabelStyle: labelStyle.copyWith(color: primaryColor),
    );
  }

  /// Стиль для переключателей
  static SwitchThemeData get switchTheme {
    return SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.white;
        }
        return Colors.white;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade400;
      }),
      trackOutlineColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade400;
      }),
    );
  }
}

/// Улучшенный CustomFormField с современным дизайном
class ModernFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final int? maxLength;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  const ModernFormField({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Метка поля
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RichText(
            text: TextSpan(
              text: label,
              style: AppInputTheme.labelStyle,
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppInputTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Поле ввода
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onTap: onTap,
          style: AppInputTheme.inputStyle.copyWith(
            color: enabled ? AppInputTheme.textPrimary : AppInputTheme.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: IconTheme(
                      data: const IconThemeData(size: 20),
                      child: prefixIcon!,
                    ),
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconTheme(
                      data: const IconThemeData(size: 20),
                      child: suffixIcon!,
                    ),
                  )
                : null,
            counterText: '',
            isDense: true,
          ).applyDefaults(AppInputTheme.inputDecorationTheme),
          validator: validator ?? _defaultValidator,
          onChanged: onChanged,
        ),
      ],
    );
  }

  String? _defaultValidator(String? value) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return 'Обязательное поле';
    }
    return null;
  }
}

/// Специализированное поле для телефона
class ModernPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final bool isRequired;
  final void Function(String)? onChanged;

  const ModernPhoneField({
    super.key,
    required this.controller,
    this.isRequired = false,
    this.onChanged,
  });

  @override
  State<ModernPhoneField> createState() => _ModernPhoneFieldState();
}

class _ModernPhoneFieldState extends State<ModernPhoneField> {
  @override
  void initState() {
    super.initState();
    // Инициализируем с +7 если поле пустое
    if (widget.controller.text.isEmpty) {
      widget.controller.text = '+7';
    }
    widget.controller.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPhoneChanged);
    super.dispose();
  }

  void _onPhoneChanged() {
    String text = widget.controller.text;
    if (!text.startsWith('+7')) {
      // Если пользователь каким-то образом удалил +7, восстанавливаем
      widget.controller.value = const TextEditingValue(
        text: '+7',
        selection: TextSelection.collapsed(offset: 2),
      );
      return;
    }

    // Оставляем только цифры после +7
    String digitsOnly = text.substring(2).replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }

    String newText = '+7$digitsOnly';
    if (newText != text) {
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernFormField(
      label: 'Телефон',
      controller: widget.controller,
      isRequired: widget.isRequired,
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone_outlined, color: AppInputTheme.textSecondary),
      hintText: '+7XXXXXXXXXX',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
      ],
      validator: (value) {
        if (widget.isRequired && (value == null || value.isEmpty)) {
          return 'Обязательное поле';
        }
        if (value != null && !RegExp(r'^\+7\d{10}$').hasMatch(value)) {
          return 'Введите корректный номер телефона';
        }
        return null;
      },
      onChanged: widget.onChanged,
    );
  }
}

/// Стилизованный переключатель
class ModernSwitchField extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  final bool enabled;

  const ModernSwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppInputTheme.labelStyle.copyWith(
              color: enabled ? AppInputTheme.textPrimary : AppInputTheme.textSecondary,
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

/// Поле для отображения в режиме только для чтения
class ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final bool isRequired;

  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RichText(
            text: TextSpan(
              text: label,
              style: AppInputTheme.labelStyle.copyWith(
                color: AppInputTheme.textSecondary,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppInputTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppInputTheme.disabledColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppInputTheme.borderColor),
          ),
          child: Text(
            value.isNotEmpty ? value : '—',
            style: AppInputTheme.inputStyle.copyWith(
              color: AppInputTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
