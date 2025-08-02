import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Добавить эту строку
import 'package:flutter/services.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/section_header.dart'; 
import '../../services/api_client.dart';
import '../../data/models/patient_model.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId; // Изменили на patientId

  const PatientDetailScreen({super.key, required this.patientId}); // Обновили конструктор

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Future<Patient> _patientFuture;
  bool _isEditing = false;
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();
  late DateTime _birthDate; // Добавляем для редактирования даты рождения
  Patient? _currentPatient;
  bool _isMale = true; 

  @override
  void initState() {
    super.initState();
    _patientFuture = _loadPatient().then((patient) {
      setState(() {
        _currentPatient = patient;
        _isMale = patient.isMale;
      });
      return patient;
    });
  }

  Future<Patient> _loadPatient() async {
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    final patient = await apiClient.getMedCardByPatientId(widget.patientId);
    _birthDate = patient.birthDate;
    
    _resetControllers();
    _initControllers(patient);
    
    return patient;
  }

  Future<void> _saveChanges() async {
    if (_currentPatient == null) return;
    
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    try {
      final updatedData = {
        "patient": {
          "id": _currentPatient!.id,
          "last_name": _controllers['lastName']!.text,
          "first_name": _controllers['firstName']!.text,
          "middle_name": _controllers['middleName']!.text,
          "birth_date": DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(
            DateTime.utc(
              _birthDate.year,
              _birthDate.month,
              _birthDate.day,
            ),
          ),
          "is_male": _isMale,
        },
        "personal_info": {
          "passport_series": '${_controllers['passportSeries']!.text} ${_controllers['passportNumber']!.text}',
          "snils": _formatSnils(_controllers['snils']!.text),
          "oms": _formatOms(_controllers['oms']!.text),
        },
        "contact_info": {
          "phone": _controllers['phone']!.text,
          "email": _controllers['email']!.text,
          "address": _controllers['address']!.text,
        },
        "allergy": _controllers['contraindications']!.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .map((e) => {"name": e})
            .toList(),
      };

      await apiClient.updateMedCard(widget.patientId, updatedData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные успешно обновлены'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Обновляем данные
      setState(() {
        _isEditing = false;
        _patientFuture = _loadPatient().then((patient) {
          _currentPatient = patient;
          return patient;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatSnils(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 11) return digits;
    
    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-'
           '${digits.substring(6, 9)} ${digits.substring(9, 11)}';
  }

  // Форматирование ОМС (XXXX XXXX XXXX XXXX)
  String _formatOms(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 16) return digits;
    
    return '${digits.substring(0, 4)} ${digits.substring(4, 8)} '
           '${digits.substring(8, 12)} ${digits.substring(12, 16)}';
  }

  void _initControllers(Patient patient) {
    _controllers['lastName'] = TextEditingController(text: patient.lastName);
    _controllers['firstName'] = TextEditingController(text: patient.firstName);
    _controllers['middleName'] = TextEditingController(text: patient.middleName);
    _isMale = patient.isMale;
    _controllers['phone'] = TextEditingController(text: patient.phone);
    _controllers['email'] = TextEditingController(text: patient.email);
    _controllers['address'] = TextEditingController(text: patient.address);
    _controllers['snils'] = TextEditingController(text: patient.snils);
    _controllers['oms'] = TextEditingController(text: patient.oms);
    _controllers['passportSeries'] = TextEditingController(text: patient.passportSeries);
    _controllers['passportNumber'] = TextEditingController(text: patient.passportNumber);
    _controllers['contraindications'] = TextEditingController(
      text: patient.allergies.join(', ')
    );
  }


void _resetControllers() {
  _controllers.forEach((key, controller) => controller.dispose());
  _controllers.clear();
}
  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _isEditing
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Пол', style: TextStyle(fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _isMale,
                      onChanged: (value) {
                        setState(() => _isMale = value ?? true);
                      },
                    ),
                    const Text('Мужской'),
                    const SizedBox(width: 20),
                    Radio<bool>(
                      value: false,
                      groupValue: _isMale,
                      onChanged: (value) {
                        setState(() => _isMale = !(value ?? false));
                      },
                    ),
                    const Text('Женский'),
                  ],
                ),
              ],
            )
          : ListTile(
              title: const Text('Пол', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(_isMale ? 'Мужской' : 'Женский'),
            ),
    );
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Patient>(
          future: _patientFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Медкарта: ${snapshot.data!.fullName}');
            }
            return const Text('Медкарта пациента');
          },
        ),
        backgroundColor: const Color(0xFF8B8B8B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditing ? 'Сохранить изменения' : 'Редактировать',
          ),
        ],
      ),
      body: FutureBuilder<Patient>(
        future: _patientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          
          final patient = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SectionHeader(title: 'Основная информация'),

                  _isEditing
                    ? Column(
                        children: [
                          _buildField(
                            label: 'Фамилия',
                            valueKey: 'lastName',
                            displayValue: patient.lastName,
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Введите фамилию' : null,
                            isRequired: true,
                          ),
                          _buildField(
                            label: 'Имя',
                            valueKey: 'firstName',
                            displayValue: patient.firstName,
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Введите имя' : null,
                            isRequired: true,
                          ),
                          _buildField(
                            label: 'Отчество',
                            valueKey: 'middleName',
                            displayValue: patient.middleName,
                            validator: (value) => null,
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: const Text('ФИО', style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            '${patient.lastName} ${patient.firstName} ${patient.middleName}'.trim(),
                          ),
                        ),
                      ),

                  _buildGenderField(),

                  _buildBirthDateField(patient),

                  SectionHeader(title: 'Документы'),

                  _buildField(
                    label: 'СНИЛС',
                    valueKey: 'snils',
                    displayValue: _formatSnils(patient.snils),
                    maxLength: 14,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите номер СНИЛСа';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                      _SnilsFormatter(),
                    ],
                  ),

                  _buildField(
                    label: 'Полис ОМС',
                    valueKey: 'oms',
                    displayValue: _formatOms(patient.oms),
                    maxLength: 19,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите номер полиса ОМС';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      _OmsFormatter(),
                    ],
                  ),

                  _buildPassportFields(patient),

                  SectionHeader(title: 'Контактная информация'),

                  _buildField(
                    label: 'Телефон',
                    valueKey: 'phone',
                    displayValue: patient.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите номер телефона';
                      }
                      return null;
                    },
                  ),

                  _buildField(
                    label: 'Email',
                    valueKey: 'email',
                    displayValue: patient.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите email';
                      }
                      return null;
                    },
                  ),

                  _buildField(
                    label: 'Адрес',
                    valueKey: 'address',
                    displayValue: patient.address,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите адрес';
                      }
                      return null;
                    },
                  ),

                  SectionHeader(title: 'Медицинская информация'),

                  _buildField(
                    label: 'Аллергии и противопоказания',
                    valueKey: 'contraindications',
                    displayValue: patient.allergies.join(', '),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите ФИО пациента';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildField({
    required String label,
    required String valueKey,
    required String displayValue,
    required String? Function(dynamic) validator,
    bool isRequired = false,
    int? maxLength,
    int? maxLines,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _isEditing
          ? CustomFormField(
              label: label,
              controller: _controllers[valueKey]!,
              isRequired: isRequired,
              maxLines: maxLines,
              maxLength: maxLength,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              validator: validator,
            )
          : ListTile(
              title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(displayValue.isEmpty ? 'Не указано' : displayValue),
            ),
    );
  }

  Widget _buildBirthDateField(Patient patient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _isEditing
          ? Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Дата рождения',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: DateFormat('dd.MM.yyyy').format(_birthDate),
                    ),
                    readOnly: true,
                  ),
                ),
                DatePickerIconButton(
                  initialDate: _birthDate,
                  onDateSelected: (date) => setState(() => _birthDate = date),
                  showDateText: false,
                ),
              ],
            )
          : ListTile(
              title: Text('Дата рождения', 
                         style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(patient.formattedBirthDate),
            ),
    );
  }
  
  // Виджет для полей паспорта
  Widget _buildPassportFields(Patient patient) {
    return _isEditing
        ? Column(
            children: [
              CustomFormField(
                label: 'Серия паспорта',
                controller: _controllers['passportSeries']!,
                maxLength: 4,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите серию паспорта';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              CustomFormField(
                label: 'Номер паспорта',
                controller: _controllers['passportNumber']!,
                maxLength: 6,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите номер паспорта';
                  }
                  return null;
                },
              ),
            ],
          )
        : ListTile(
            title: Text('Паспорт', 
                       style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
              patient.passportSeries.isNotEmpty && patient.passportNumber.isNotEmpty
                  ? '${patient.passportSeries} ${patient.passportNumber}'
                  : 'Не указан',
            ),
          );
  }

  void _toggleEditMode() {
    if (_isEditing) {
      if (_formKey.currentState!.validate()) {
        _saveChanges(); // Вызываем сохранение данных
      }
    } else {
      setState(() => _isEditing = true);
    }
  }
}

// Новые форматтеры для полей
class _SnilsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) return newValue;
    
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) formatted += '-';
      if (i == 9) formatted += ' ';
      if (i < 11) formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _OmsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) return newValue;
    
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 4 || i == 8 || i == 12) formatted += ' ';
      if (i < 16) formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}