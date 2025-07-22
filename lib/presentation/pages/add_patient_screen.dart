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
  final Map<String, String> _patientData = {
    'fullName': '',
    'gender': '',
    'passportSeries': '',
    'passportNumber': '',
    'snils': '',
    'oms': '',
    'address': '',
    'phone': '',
    'email': '',
    'contraindications': '',
  };

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
                controller: TextEditingController(text: _patientData['fullName']),
                isRequired: true,
              ),
              
              // Пол
              _buildGenderDropdown(),

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
                    initialDate: _patientData['birthDate'] != null 
                        ? DateFormat('dd.MM.yyyy').parse(_patientData['birthDate']!)
                        : null,
                    onDateSelected: (date) {
                      setState(() {
                        _patientData['birthDate'] = DateFormat('dd.MM.yyyy').format(date);
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _patientData['birthDate'] ?? 'Дата не выбрана',
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
                      controller: TextEditingController(text: _patientData['passportSeries']),
                      maxLength: 4,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomFormField(
                      label: 'Номер',
                      controller: TextEditingController(text: _patientData['passportNumber']),
                      maxLength: 6,
                    ),
                  ),
                ],
              ),
              
              // СНИЛС
              CustomFormField(
                      label: 'СНИЛС',
                      controller: TextEditingController(text: _patientData['snils']),
                      maxLength: 11,
              ),
              
              // ОМС
              CustomFormField(
                      label: 'Полис ОМС',
                      controller: TextEditingController(text: _patientData['oms']),
                      maxLength: 16,
              ),
                      
              
              // Адрес
              CustomFormField(
                      label: 'Адрес проживания',
                      controller: TextEditingController(text: _patientData['address']),
              ),
              
              // Контактная информация
              const SizedBox(height: 10),
              const Text('Контактная информация', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              CustomFormField(
                      label: 'Номер телефона',
                      controller: TextEditingController(text: _patientData['phone']),
                      keyboardType: TextInputType.phone,
              ),
              CustomFormField(
                      label: 'Электронная почта',
                      controller: TextEditingController(text: _patientData['email']),
                      keyboardType: TextInputType.emailAddress,
              ),
              
              // Противопоказания
              const SizedBox(height: 10),
              CustomFormField(
                      label: 'Противопоказания',
                      controller: TextEditingController(text: _patientData['contraindications']),
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
        decoration: const InputDecoration(
          labelText: 'Пол',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: const [
          DropdownMenuItem(value: 'Мужской', child: Text('Мужской')),
          DropdownMenuItem(value: 'Женский', child: Text('Женский')),
        ],
        onChanged: (value) => _patientData['gender'] = value ?? '',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Выберите пол';
          }
          return null;
        },
      ),
    );
  }

  void _savePatient() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // В реальном приложении здесь будет сохранение в базу данных
      // Сейчас просто показываем сообщение и закрываем экран
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Новый пациент успешно зарегистрирован'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Закрываем экран
      Navigator.pop(context);
    }
  }
}