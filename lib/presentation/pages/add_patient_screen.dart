import 'package:demo_app/services/api_client.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/custom_form_field.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passportSeriesController = TextEditingController();
  final TextEditingController _passportNumberController = TextEditingController();
  final TextEditingController _snilsController = TextEditingController();
  final TextEditingController _omsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contraindicationsController = TextEditingController();
  
  String? _gender;
  DateTime? _birthDate;

  @override
  void dispose() {
    _fullNameController.dispose();
    _passportSeriesController.dispose();
    _passportNumberController.dispose();
    _snilsController.dispose();
    _omsController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _contraindicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить пациента'),
        backgroundColor: const Color(0xFF8B8B8B), // Серый
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // ФИО
            CustomFormField(
              label: 'ФИО',
              controller: _fullNameController,
              isRequired: true,
            ),
            
            // Пол
            _buildGenderDropdown(),
            
            // Дата рождения
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    'Дата рождения',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 10),
                DatePickerIconButton(
                  initialDate: _birthDate,
                  onDateSelected: (date) => setState(() => _birthDate = date),
                ),
                const SizedBox(width: 10),
                Text(
                  _birthDate != null 
                    ? DateFormat('dd.MM.yyyy').format(_birthDate!)
                    : 'Дата не выбрана',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
              // Паспортные данные
              const SizedBox(height: 10),
              const Text('Паспортные данные', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: CustomFormField(
                      label: 'Серия',
                      controller: _passportSeriesController,
                      maxLength: 4,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomFormField(
                      label: 'Номер',
                      controller: _passportNumberController,
                      maxLength: 6,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              // СНИЛС
              CustomFormField(
                      label: 'СНИЛС',
                      controller: _snilsController,
                      maxLength: 11,
                      isRequired: true,
              ),
              // ОМС
              CustomFormField(
                      label: 'Полис ОМС',
                      controller: _omsController,
                      maxLength: 16,
                      isRequired: true,
              ),
              // Адрес
              CustomFormField(
                      label: 'Адрес проживания',
                      controller: _addressController,
              ),
              // Контактная информация
              const SizedBox(height: 10),
              const Text('Контактная информация', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              CustomFormField(
                      label: 'Номер телефона',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
              ),
              CustomFormField(
                      label: 'Электронная почта',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
              ),
              // Противопоказания
              const SizedBox(height: 10),
              CustomFormField(
                      label: 'Противопоказания',
                      controller: _contraindicationsController,
                      maxLines: 3,
              ),
              // Кнопки
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text('Отмена', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _savePatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B8B8B),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _gender,
        decoration: const InputDecoration(
          labelText: 'Пол*',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: const [
          DropdownMenuItem(value: 'Мужской', child: Text('Мужской')),
          DropdownMenuItem(value: 'Женский', child: Text('Женский')),
        ],
        onChanged: (value) => setState(() => _gender = value),
        validator: (value) => value == null ? 'Выберите пол' : null,
      ),
    );
  }

  void _savePatient() async {
  if (_formKey.currentState!.validate()) {
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите дату рождения'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      // Форматирование данных в соответствии с требованиями API
      final patientData = {
        "patient": {
          "full_name": _fullNameController.text,
          "birth_date": DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(
            DateTime.utc(
              _birthDate!.year,
              _birthDate!.month,
              _birthDate!.day,
            ),
          ),
          "is_male": _gender == 'Мужской',
        },
        "personal_info": {
          "passport_series": '${_passportSeriesController.text} ${_passportNumberController.text}',
          "snils": _formatSnils(_snilsController.text),
          "oms": _formatOms(_omsController.text),
        },
        "contact_info": {
          "phone": _phoneController.text,
          "email": _emailController.text,
          "address": _addressController.text,
        },
        "allergy": _contraindicationsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .map((e) => {"name": e})
            .toList(),
      };
      await apiClient.createPatient(patientData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Новый пациент успешно зарегистрирован'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
// Функции форматирования СНИЛС и ОМС
String _formatSnils(String input) {
  final digits = input.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.length < 11) return digits;
  return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-'
         '${digits.substring(6, 9)} ${digits.substring(9, 11)}';
}
String _formatOms(String input) {
  final digits = input.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.length < 16) return digits;
  return '${digits.substring(0, 4)} ${digits.substring(4, 8)} '
         '${digits.substring(8, 12)} ${digits.substring(12, 16)}';
}
}