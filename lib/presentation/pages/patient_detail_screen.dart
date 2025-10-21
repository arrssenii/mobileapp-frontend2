import 'package:kvant_medpuls/presentation/widgets/phone_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Добавить эту строку
import 'package:flutter/services.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/date_picker_icon_button.dart';
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
  String _docType = 'Паспорт гражданина';

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
          "additional_phone": _controllers['additionalPhone']!.text,
          "legal_representative": _controllers['legalRepresentative']!.text,
          "workplace": _controllers['workplace']!.text,
        },
        "relative_info": {
          "status": _controllers['relativeStatus']!.text,
          "name": _controllers['relativeName']!.text,
        },
        "doctor_info": {
          "name": _controllers['doctorName']!.text,
          "certificate": _controllers['doctorCertificate']!.text,
          "start_date": _controllers['doctorStartDate']!.text,
          "end_date": _controllers['doctorEndDate']!.text,
          "clinic": _controllers['doctorClinic']!.text,
        },
        "policy_info": {
          "type": _controllers['policyType']!.text,
          "valid_from": _controllers['policyValidFrom']!.text,
          "valid_to": _controllers['policyValidTo']!.text,
          "contractor": _controllers['policyContractor']!.text,
        },
        "certificate_info": {
          "type": _controllers['certificateType']!.text,
          "start_date": _controllers['certificateStartDate']!.text,
          "end_date": _controllers['certificateEndDate']!.text,
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
    // Добавляем контроллеры для новых полей
    _controllers['additionalPhone'] = TextEditingController(text: '');
    _controllers['legalRepresentative'] = TextEditingController(text: '');
    _controllers['relativeStatus'] = TextEditingController(text: '');
    _controllers['relativeName'] = TextEditingController(text: '');
    _controllers['workplace'] = TextEditingController(text: '');
    _controllers['doctorName'] = TextEditingController(text: '');
    _controllers['doctorCertificate'] = TextEditingController(text: '');
    _controllers['doctorStartDate'] = TextEditingController(text: '');
    _controllers['doctorEndDate'] = TextEditingController(text: '');
    _controllers['doctorClinic'] = TextEditingController(text: '');
    _controllers['policyType'] = TextEditingController(text: 'ОМС');
    _controllers['policyValidFrom'] = TextEditingController(text: '');
    _controllers['policyValidTo'] = TextEditingController(text: '');
    _controllers['policyContractor'] = TextEditingController(text: '');
    _controllers['certificateType'] = TextEditingController(text: '');
    _controllers['certificateStartDate'] = TextEditingController(text: '');
    _controllers['certificateEndDate'] = TextEditingController(text: '');
  }

  void _resetControllers() {
    _controllers.forEach((key, controller) => controller.dispose());
    _controllers.clear();
  }

  Widget _buildGenderField() {
    return _isEditing
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Пол', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _isMale ? 'Мужской' : 'Женский',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Мужской', child: Text('Мужской')),
                  DropdownMenuItem(value: 'Женский', child: Text('Женский')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _isMale = value == 'Мужской');
                  }
                },
              ),
            ],
          )
        : _buildReadOnlyField('Пол', _isMale ? 'Мужской' : 'Женский');
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
                return Text('Карточка пациента: ${snapshot.data!.fullName}');
              }
              return const Text('Карточка пациента');
            },
          ),
          backgroundColor: const Color(0xFF5F9EA0),
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
            
            if (!snapshot.hasData) {
              return const Center(child: Text('Данные пациента не найдены'));
            }
            
            final patient = snapshot.data!;
            _currentPatient = patient;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Основные поля для редактирования
                    if (_isEditing) ...[
                      // Фамилия и Имя
                      Row(
                        children: [
                          Expanded(child: _buildNameField('Фамилия', 'lastName', patient.lastName, true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildNameField('Имя', 'firstName', patient.firstName, true)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Отчество и Дата рождения
                      Row(
                        children: [
                          Expanded(child: _buildNameField('Отчество', 'middleName', patient.middleName, false)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildBirthDateField(patient)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Телефон и СНИЛС
                      Row(
                        children: [
                          Expanded(child: _buildContactField('Телефон', 'phone', patient.phone, true, TextInputType.phone)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDocumentField('СНИЛС', 'snils', _formatSnils(patient.snils), true, [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                            _SnilsFormatter(),
                          ])),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Тип документа и Пол
                      Row(
                        children: [
                          Expanded(child: _buildDocTypeField()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildGenderField()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Серия и Номер документа
                      Row(
                        children: [
                          Expanded(child: _buildDocumentField('Серия', 'passportSeries', patient.passportSeries, true, [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ])),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDocumentField('Номер', 'passportNumber', patient.passportNumber, true, [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ])),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Адрес и Полис
                      Row(
                        children: [
                          Expanded(child: _buildContactField('Адрес', 'address', patient.address, true, null, maxLines: 1)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDocumentField('Полис ОМС', 'oms', _formatOms(patient.oms), true, [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                            _OmsFormatter(),
                          ])),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildContactField('Email', 'email', patient.email, false, TextInputType.emailAddress),
                      const SizedBox(height: 16),

                      // Дополнительные поля из HTML
                      _buildContactField('Дополнительный телефон', 'additionalPhone', '', false, TextInputType.phone),
                      const SizedBox(height: 16),

                      _buildContactField('Законный представитель', 'legalRepresentative', '', false, null),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(child: _buildContactField('Статус родственника', 'relativeStatus', '', false, null)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildContactField('Имя родственника', 'relativeName', '', false, null)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildContactField('Место работы', 'workplace', '', false, null),
                      const SizedBox(height: 16),

                      // Лечащий врач
                      const Text('Лечащий врач', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildContactField('ФИО врача', 'doctorName', '', false, null)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildContactField('Номер сертификата', 'doctorCertificate', '', false, null)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildContactField('Начало прикрепления', 'doctorStartDate', '', false, null)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildContactField('Конец прикрепления', 'doctorEndDate', '', false, null)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildContactField('Клиника', 'doctorClinic', '', false, null),
                      const SizedBox(height: 16),

                      // Полис
                      const Text('Полис', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildContactField('Вид полиса', 'policyType', 'ОМС', false, null)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildContactField('Срок действия (с)', 'policyValidFrom', '', false, null)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildContactField('Срок действия (по)', 'policyValidTo', '', false, null)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildContactField('Контрагент', 'policyContractor', '', false, null)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Сертификат
                      const Text('Сертификат', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildContactField('Вид сертификата', 'certificateType', '', false, null)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildContactField('Дата начала', 'certificateStartDate', '', false, null)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildContactField('Дата окончания', 'certificateEndDate', '', false, null),
                      const SizedBox(height: 16),

                      // Аллергии
                      _buildContactField('Аллергии', 'contraindications', patient.allergies.join(', '), false, null, maxLines: 3),
                      const SizedBox(height: 24),
                    ] else ...[
                      // Структурированные поля для режима просмотра
                      // 1. Представление
                      _buildSectionField('1. Представление', patient.fullName),
                      const SizedBox(height: 16),

                      // 2. Возраст
                      _buildSectionField('2. Возраст', _calculateAge(patient.birthDate)),
                      const SizedBox(height: 16),

                      // 3. Дата рождения
                      _buildSectionField('3. Дата рождения', patient.formattedBirthDate),
                      const SizedBox(height: 16),

                      // 4. Телефон (мобильный)
                      _buildSectionField('4. Телефон (мобильный)', patient.phone),
                      const SizedBox(height: 16),

                      // 5. Сотовый телефон (Доп. телефон)
                      _buildSectionField('5. Сотовый телефон (Доп. телефон)', 'Не указано'),
                      const SizedBox(height: 16),

                      // 6. Адрес (Фактический)
                      _buildSectionField('6. Адрес (Фактический)', patient.address),
                      const SizedBox(height: 16),

                      // 7. Адрес электронной почты
                      _buildSectionField('7. Адрес электронной почты', patient.email),
                      const SizedBox(height: 16),

                      // 8. Законный представитель
                      _buildSectionField('8. Законный представитель', 'Не указано'),
                      const SizedBox(height: 16),

                      // 9. Родственник
                      _buildRelativeSection(),
                      const SizedBox(height: 16),

                      // 10. Место работы
                      _buildSectionField('10. Место работы', 'Не указано'),
                      const SizedBox(height: 16),

                      // 11. Лечащий врач
                      _buildDoctorSection(),
                      const SizedBox(height: 16),

                      // 12. СНИЛС
                      _buildSectionField('12. СНИЛС', _formatSnils(patient.snils)),
                      const SizedBox(height: 16),

                      // 13. Полис
                      _buildPolicySection(patient),
                      const SizedBox(height: 16),

                      // 14. Сертификат
                      _buildCertificateSection(),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  

  Widget _buildNameField(String label, String key, String value, bool isRequired) {
    return _isEditing
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              CustomFormField(
                label: label,
                controller: _controllers[key]!,
                isRequired: isRequired,
                showLabelInside: false,  // Отключаем встроенный label
              ),
            ],
          )
        : _buildReadOnlyField(label, value);
  }


  Widget _buildContactField(String label, String key, String value, bool isRequired, TextInputType? keyboardType, {int maxLines = 1,}) {
    if (_isEditing) {
      // Режим редактирования — обычный текстовый input
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          CustomFormField(
            label: label,
            controller: _controllers[key]!,
            isRequired: isRequired,
            keyboardType: keyboardType,
            maxLines: maxLines,
            showLabelInside: false,
            inputFormatters: label == 'Телефон'
                ? [
                    // Авто-подстановка "+"
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      String text = newValue.text;
                      if (!text.startsWith('+')) {
                        text = '+' + text.replaceAll('+', '');
                      }
                      if (text.length > 15) text = text.substring(0, 15);
                      return TextEditingValue(
                        text: text,
                        selection: TextSelection.collapsed(offset: text.length),
                      );
                    }),
                    FilteringTextInputFormatter.allow(RegExp(r'^\+?\d*')),
                    LengthLimitingTextInputFormatter(15),
                  ]
                : null,
          ),
        ],
      );
    } else {
      // Режим просмотра
      if (label == 'Телефон') {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: PhoneField(phone: value),
          ),
        );
      } else {
        return _buildReadOnlyField(label, value, maxLines: maxLines);
      }
    }
  }


  Widget _buildDocumentField(String label, String key, String value, bool isRequired, List<TextInputFormatter>? formatters) {
    return _isEditing
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              CustomFormField(
                label: label,
                controller: _controllers[key]!,
                isRequired: isRequired,
                inputFormatters: formatters,
                showLabelInside: false,
              ),
            ],
          )
        : _buildReadOnlyField(label, value);
  }

  Widget _buildReadOnlyField(String label, String value, {int maxLines = 1}) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? 'Не указано' : value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildDocTypeField() {
    return _isEditing
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Тип документа', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _docType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Паспорт гражданина', child: Text('Паспорт гражданина')),
                  DropdownMenuItem(value: 'Свидетельство о рождении', child: Text('Свидетельство о рождении')),
                  DropdownMenuItem(value: 'Заграничный паспорт', child: Text('Заграничный паспорт')),
                ],
                onChanged: (value) => setState(() => _docType = value!),
              ),
            ],
          )
        : _buildReadOnlyField('Тип документа', _docType);
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => setState(() => _isEditing = false),
          child: const Text('Отмена', style: TextStyle(color: Colors.red)),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B8B8B),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildBirthDateField(Patient patient) {
    return _isEditing
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Дата рождения', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                      child: Text(DateFormat('dd.MM.yyyy').format(_birthDate)),
                    ),
                  ),
                  DatePickerIconButton(
                    initialDate: _birthDate,
                    onDateSelected: (date) => setState(() => _birthDate = date),
                  ),
                ],
              ),
            ],
          )
        : _buildReadOnlyField('Дата рождения', patient.formattedBirthDate);
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

  // Новые методы для структурированных полей
  Widget _buildSectionField(String label, String value) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value.isEmpty ? 'Не указано' : value,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.grey[300],
    );
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return '$age лет';
  }

  Widget _buildRelativeSection() {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '9. Родственник',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Статус родственника',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Не указано',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Наименование',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Не указано',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
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

  Widget _buildDoctorSection() {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '11. Лечащий врач',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFe8f5e9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Информация о враче',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ФИО врача',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Не указано',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Номер полиса/сертификата',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Не указано',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Начало прикрепления',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Не указано',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Конец прикрепления',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Не указано',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Клиника',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Не указано',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection(Patient patient) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '13. Полис',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFe8f5e9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Информация о полисе',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Вид полиса',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ОМС',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Номер',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatOms(patient.oms).isEmpty ? 'Не указано' : _formatOms(patient.oms),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Срок действия',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Не указано',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Контрагент',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Не указано',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateSection() {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '14. Сертификат',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFe8f5e9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Информация о сертификате',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Вид сертификата',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Не указано',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Дата начала действия',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Не указано',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Дата окончания действия',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Не указано',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
