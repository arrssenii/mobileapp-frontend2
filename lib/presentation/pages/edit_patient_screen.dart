
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/design_system/input_fields.dart';

class EditPatientScreen extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const EditPatientScreen({
    super.key,
    required this.patientId,
    required this.patientData,
  });

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _mobilePhoneController = TextEditingController();
  final TextEditingController _additionalPhoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _snilsController = TextEditingController();
  final TextEditingController _workplaceController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  // Контроллеры для лечащего врача
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _doctorCertNumberController = TextEditingController();
  final TextEditingController _doctorClinicController = TextEditingController();
  final TextEditingController _doctorStartDateController = TextEditingController();
  final TextEditingController _doctorEndDateController = TextEditingController();

  // Контроллеры для полиса
  final TextEditingController _policyTypeController = TextEditingController();
  final TextEditingController _policyNumberController = TextEditingController();

  // Контроллеры для сертификата
  final TextEditingController _certificateDateController = TextEditingController();
  final TextEditingController _certificateNumberController = TextEditingController();

  // Контроллеры для законного представителя
  final TextEditingController _legalRepIdController = TextEditingController();
  final TextEditingController _legalRepNameController = TextEditingController();

  // Контроллеры для родственника
  final TextEditingController _relativeStatusController = TextEditingController();
  final TextEditingController _relativeNameController = TextEditingController();

  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  void _loadPatientData() {
    final patientData = widget.patientData;
    
    // Основные данные пациента
    _displayNameController.text = patientData['display_name'] ?? '';
    _mobilePhoneController.text = patientData['mobile_phone'] ?? '';
    _additionalPhoneController.text = patientData['additional_phone'] ?? '';
    _emailController.text = patientData['email'] ?? '';
    _addressController.text = patientData['address'] ?? '';
    _snilsController.text = patientData['snils'] ?? '';
    _workplaceController.text = patientData['workplace'] ?? '';
    
    // Обрабатываем дату рождения
    final birthDateStr = patientData['birth_date'];
    if (birthDateStr != null && birthDateStr.isNotEmpty) {
      try {
        _birthDate = DateFormat('yyyy-MM-dd').parse(birthDateStr);
        _birthDateController.text = DateFormat('dd.MM.yyyy').format(_birthDate!);
      } catch (e) {
        debugPrint('Ошибка парсинга даты рождения: $e');
      }
    }

    // Данные лечащего врача
    final doctor = patientData['attending_doctor'];
    if (doctor != null) {
      _doctorNameController.text = doctor['full_name'] ?? '';
      _doctorCertNumberController.text = doctor['policy_or_cert_number'] ?? '';
      _doctorClinicController.text = doctor['clinic'] ?? '';
      _doctorStartDateController.text = doctor['attachment_start'] ?? '';
      _doctorEndDateController.text = doctor['attachment_end'] ?? '';
    }

    // Данные полиса
    final policy = patientData['policy'];
    if (policy != null) {
      _policyTypeController.text = policy['type'] ?? '';
      _policyNumberController.text = policy['number'] ?? '';
    }

    // Данные сертификата
    final certificate = patientData['certificate'];
    if (certificate != null) {
      _certificateDateController.text = certificate['date'] ?? '';
      _certificateNumberController.text = certificate['number'] ?? '';
    }

    // Данные законного представителя
    final legalRep = patientData['legal_representative'];
    if (legalRep != null) {
      _legalRepIdController.text = legalRep['id']?.toString() ?? '';
      _legalRepNameController.text = legalRep['name'] ?? '';
    }

    // Данные родственника
    final relative = patientData['relative'];
    if (relative != null) {
      _relativeStatusController.text = relative['status'] ?? '';
      _relativeNameController.text = relative['name'] ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _mobilePhoneController.dispose();
    _additionalPhoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _snilsController.dispose();
    _workplaceController.dispose();
    _birthDateController.dispose();
    
    _doctorNameController.dispose();
    _doctorCertNumberController.dispose();
    _doctorClinicController.dispose();
    _doctorStartDateController.dispose();
    _doctorEndDateController.dispose();
    
    _policyTypeController.dispose();
    _policyNumberController.dispose();
    
    _certificateDateController.dispose();
    _certificateNumberController.dispose();
    
    _legalRepIdController.dispose();
    _legalRepNameController.dispose();
    
    _relativeStatusController.dispose();
    _relativeNameController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Редактировать пациента',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Отображаемое имя
                    ModernFormField(
                      label: 'Отображаемое имя',
                      controller: _displayNameController,
                      isRequired: true,
                      prefixIcon: const Icon(Icons.person_outline, color: AppInputTheme.textSecondary),
                      hintText: 'Введите ФИО пациента',
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),

                    // Мобильный телефон
                    ModernFormField(
                      label: 'Мобильный телефон',
                      controller: _mobilePhoneController,
                      prefixIcon: const Icon(Icons.phone, color: AppInputTheme.textSecondary),
                      hintText: '+7 (XXX) XXX-XX-XX',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    // Дополнительный телефон
                    ModernFormField(
                      label: 'Дополнительный телефон',
                      controller: _additionalPhoneController,
                      prefixIcon: const Icon(Icons.phone_android, color: AppInputTheme.textSecondary),
                      hintText: '+7 (XXX) XXX-XX-XX',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    // Email
                    ModernFormField(
                      label: 'Email',
                      controller: _emailController,
                      prefixIcon: const Icon(Icons.email, color: AppInputTheme.textSecondary),
                      hintText: 'example@mail.ru',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Адрес
                    ModernFormField(
                      label: 'Адрес',
                      controller: _addressController,
                      prefixIcon: const Icon(Icons.home, color: AppInputTheme.textSecondary),
                      hintText: 'Введите адрес проживания',
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 20),

                    // СНИЛС
                    ModernFormField(
                      label: 'СНИЛС',
                      controller: _snilsController,
                      prefixIcon: const Icon(Icons.credit_card, color: AppInputTheme.textSecondary),
                      hintText: 'XXX-XXX-XXX XX',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    // Место работы
                    ModernFormField(
                      label: 'Место работы',
                      controller: _workplaceController,
                      prefixIcon: const Icon(Icons.work, color: AppInputTheme.textSecondary),
                      hintText: 'Введите место работы',
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 20),

                    // Дата рождения
                    _buildBirthDateField(),
                    const SizedBox(height: 20),

                    // Лечащий врач
                    _buildDoctorSection(),
                    const SizedBox(height: 20),

                    // Полис
                    _buildPolicySection(),
                    const SizedBox(height: 20),

                    // Сертификат
                    _buildCertificateSection(),
                    const SizedBox(height: 20),

                    // Законный представитель
                    _buildLegalRepresentativeSection(),
                    const SizedBox(height: 20),

                    // Родственник
                    _buildRelativeSection(),
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
                onDateSelected: (date) {
                  setState(() {
                    _birthDate = date;
                    _birthDateController.text = DateFormat('dd.MM.yyyy').format(date);
                  });
                },
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

  Widget _buildDoctorSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Лечащий врач',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'ФИО врача',
              controller: _doctorNameController,
              prefixIcon: const Icon(Icons.medical_services, color: AppInputTheme.textSecondary),
              hintText: 'Введите ФИО врача',
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'Номер сертификата',
              controller: _doctorCertNumberController,
              prefixIcon: const Icon(Icons.badge, color: AppInputTheme.textSecondary),
              hintText: 'Введите номер сертификата',
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'Клиника',
              controller: _doctorClinicController,
              prefixIcon: const Icon(Icons.local_hospital, color: AppInputTheme.textSecondary),
              hintText: 'Введите название клиники',
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'Начало прикрепления',
              controller: _doctorStartDateController,
              prefixIcon: const Icon(Icons.calendar_today, color: AppInputTheme.textSecondary),
              hintText: 'Дата начала прикрепления',
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'Конец прикрепления',
              controller: _doctorEndDateController,
              prefixIcon: const Icon(Icons.calendar_today, color: AppInputTheme.textSecondary),
              hintText: 'Дата окончания прикрепления',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Полис',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'Тип полиса',
              controller: _policyTypeController,
              prefixIcon: const Icon(Icons.credit_card, color: AppInputTheme.textSecondary),
              hintText: 'Тип полиса',
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'Номер полиса',
              controller: _policyNumberController,
              prefixIcon: const Icon(Icons.numbers, color: AppInputTheme.textSecondary),
              hintText: 'Номер полиса',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Сертификат',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'Дата',
              controller: _certificateDateController,
              prefixIcon: const Icon(Icons.calendar_today, color: AppInputTheme.textSecondary),
              hintText: 'Дата сертификата',
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'Номер',
              controller: _certificateNumberController,
              prefixIcon: const Icon(Icons.numbers, color: AppInputTheme.textSecondary),
              hintText: 'Номер сертификата',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalRepresentativeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Законный представитель',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'ID',
              controller: _legalRepIdController,
              prefixIcon: const Icon(Icons.person, color: AppInputTheme.textSecondary),
              hintText: 'ID представителя',
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'Имя',
              controller: _legalRepNameController,
              prefixIcon: const Icon(Icons.person_outline, color: AppInputTheme.textSecondary),
              hintText: 'Имя представителя',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelativeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Родственник',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'Статус',
              controller: _relativeStatusController,
              prefixIcon: const Icon(Icons.family_restroom, color: AppInputTheme.textSecondary),
              hintText: 'Статус родственника',
            ),
            const SizedBox(height: 12),
            ModernFormField(
              label: 'Имя',
              controller: _relativeNameController,
              prefixIcon: const Icon(Icons.person_outline, color: AppInputTheme.textSecondary),
              hintText: 'Имя родственника',
            ),
          ],
        ),
      ),
    );
  }

  void _savePatient() async {
    if (_formKey.currentState!.validate()) {
      if (_birthDate == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Выберите дату рождения'),
            backgroundColor: AppInputTheme.errorColor,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final apiClient = Provider.of<ApiClient>(context, listen: false);
        
        // Подготавливаем данные для обновления
        final Map<String, dynamic> updateData = {
          'display_name': _displayNameController.text.trim(),
          'mobile_phone': _mobilePhoneController.text.trim(),
          'additional_phone': _additionalPhoneController.text.trim(),
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
          'snils': _snilsController.text.trim(),
          'workplace': _workplaceController.text.trim(),
          'birth_date': DateFormat('yyyy-MM-dd').format(_birthDate!),
        };

        // Добавляем данные лечащего врача, если они заполнены
        if (_doctorNameController.text.isNotEmpty ||
            _doctorCertNumberController.text.isNotEmpty ||
            _doctorClinicController.text.isNotEmpty ||
            _doctorStartDateController.text.isNotEmpty ||
            _doctorEndDateController.text.isNotEmpty) {
          updateData['attending_doctor'] = {
            'full_name': _doctorNameController.text.trim(),
            'policy_or_cert_number': _doctorCertNumberController.text.trim(),
            'clinic': _doctorClinicController.text.trim(),
            'attachment_start': _doctorStartDateController.text.trim(),
            'attachment_end': _doctorEndDateController.text.trim(),
          };
        }

        // Добавляем данные полиса, если они заполнены
        if (_policyTypeController.text.isNotEmpty || _policyNumberController.text.isNotEmpty) {
          updateData['policy'] = {
            'type': _policyTypeController.text.trim(),
            'number': _policyNumberController.text.trim(),
          };
        }

        // Добавляем данные сертификата, если они заполнены
        if (_certificateDateController.text.isNotEmpty || _certificateNumberController.text.isNotEmpty) {
          updateData['certificate'] = {
            'date': _certificateDateController.text.trim(),
            'number': _certificateNumberController.text.trim(),
          };
        }

        // Добавляем данные законного представителя, если они заполнены
        if (_legalRepIdController.text.isNotEmpty || _legalRepNameController.text.isNotEmpty) {
          updateData['legal_representative'] = {
            'id': _legalRepIdController.text.trim(),
            'name': _legalRepNameController.text.trim(),
          };
        }

        // Добавляем данные родственника, если они заполнены
        if (_relativeStatusController.text.isNotEmpty || _relativeNameController.text.isNotEmpty) {
          updateData['relative'] = {
            'status': _relativeStatusController.text.trim(),
            'name': _relativeNameController.text.trim(),
          };
        }

        // Удаляем пустые поля
        updateData.removeWhere((key, value) {
          if (value is Map<String, dynamic>) {
            return value.values.every((v) => v.toString().isEmpty);
          }
          return value.toString().isEmpty;
        });

        // Обновляем данные пациента
        await apiClient.updatePatient(widget.patientId, updateData);

        // Показываем сообщение об успехе
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Данные пациента успешно обновлены'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Возвращаемся на предыдущий экран с обновленными данными
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        debugPrint('Ошибка обновления пациента: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления: ${e.toString()}'),
            backgroundColor: AppInputTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
