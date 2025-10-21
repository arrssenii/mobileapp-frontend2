import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/design_system/input_fields.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();

  String? _gender;
  DateTime? _birthDate;

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Добавить пациента',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppInputTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Фамилия
              ModernFormField(
                label: 'Фамилия',
                controller: _lastNameController,
                isRequired: true,
                prefixIcon: const Icon(Icons.person_outline, color: AppInputTheme.textSecondary),
                hintText: 'Введите фамилию',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

              // Имя
              ModernFormField(
                label: 'Имя',
                controller: _firstNameController,
                isRequired: true,
                prefixIcon: const Icon(Icons.person_outline, color: AppInputTheme.textSecondary),
                hintText: 'Введите имя',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

              // Отчество
              ModernFormField(
                label: 'Отчество',
                controller: _middleNameController,
                isRequired: true,
                prefixIcon: const Icon(Icons.person_outline, color: AppInputTheme.textSecondary),
                hintText: 'Введите отчество',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

              // Пол
              _buildGenderDropdown(),
              const SizedBox(height: 20),

              // Дата рождения
              _buildBirthDateField(),
              const SizedBox(height: 40),

              // Кнопки
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppInputTheme.textSecondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Отмена',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _savePatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppInputTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Сохранить',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RichText(
            text: TextSpan(
              text: 'Пол',
              style: AppInputTheme.labelStyle,
              children: const [
                TextSpan(
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
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.transgender, color: AppInputTheme.textSecondary),
            isDense: true,
          ).applyDefaults(AppInputTheme.inputDecorationTheme),
          items: const [
            DropdownMenuItem(
              value: 'Мужской',
              child: Text('Мужской'),
            ),
            DropdownMenuItem(
              value: 'Женский',
              child: Text('Женский'),
            ),
          ],
          onChanged: (value) => setState(() => _gender = value),
          validator: (value) => value == null ? 'Выберите пол' : null,
        ),
      ],
    );
  }

  Widget _buildBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RichText(
            text: TextSpan(
              text: 'Дата рождения',
              style: AppInputTheme.labelStyle,
              children: const [
                TextSpan(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _birthDate == null ? AppInputTheme.borderColor : AppInputTheme.primaryColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: AppInputTheme.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _birthDate != null
                      ? DateFormat('dd.MM.yyyy').format(_birthDate!)
                      : 'Выберите дату рождения',
                  style: TextStyle(
                    fontSize: 16,
                    color: _birthDate != null ? AppInputTheme.textPrimary : AppInputTheme.textSecondary,
                  ),
                ),
              ),
              DatePickerIconButton(
                initialDate: _birthDate,
                onDateSelected: (date) => setState(() => _birthDate = date),
              ),
            ],
          ),
        ),
        if (_birthDate == null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Выберите дату рождения',
              style: AppInputTheme.errorStyle.copyWith(
                color: AppInputTheme.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  void _savePatient() {
    if (_formKey.currentState!.validate()) {
      if (_birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Выберите дату рождения'),
            backgroundColor: AppInputTheme.errorColor,
          ),
        );
        return;
      }

      final patientData = {
        'lastName': _lastNameController.text,
        'firstName': _firstNameController.text,
        'middleName': _middleNameController.text,
        'birthDate': DateFormat('yyyy-MM-dd').format(_birthDate!),
        'gender': _gender!,
      };

      Navigator.pop(context, patientData);
    }
  }
}
