import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/section_header.dart';
import '../widgets/custom_form_field.dart'; // Новый импорт
import '../widgets/date_picker_icon_button.dart'; // Новый импорт

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  bool _isEditing = false;
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _controllers['fullName'] = TextEditingController(text: widget.patient['fullName'] ?? '');
    _controllers['gender'] = TextEditingController(text: widget.patient['gender'] ?? '');
    _controllers['birthDate'] = TextEditingController(text: widget.patient['birthDate'] ?? '');
    _controllers['snils'] = TextEditingController(text: widget.patient['snils'] ?? '');
    _controllers['oms'] = TextEditingController(text: widget.patient['oms'] ?? '');
    // Разделение паспорта на серию и номер
    _controllers['passportSeries'] = TextEditingController(text: widget.patient['passportSeries'] ?? '');
    _controllers['passportNumber'] = TextEditingController(text: widget.patient['passportNumber'] ?? '');
    _controllers['phone'] = TextEditingController(text: widget.patient['phone'] ?? '');
    _controllers['email'] = TextEditingController(text: widget.patient['email'] ?? '');
    _controllers['contraindications'] = TextEditingController(text: widget.patient['contraindications'] ?? '');
    _controllers['address'] = TextEditingController(text: widget.patient['address'] ?? '');
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
        title: Text('Медкарта: ${widget.patient['fullName']}'),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SectionHeader(title: 'Основная информация'),
              
              // ФИО
              _buildField(
                label: 'ФИО',
                valueKey: 'fullName',
                isRequired: true,
              ),
              
              // Пол
              _buildGenderField(),
              
              // Дата рождения
              _buildBirthDateField(),
              
              SectionHeader(title: 'Документы'),
              
              // СНИЛС
              _buildField(
                label: 'СНИЛС',
                valueKey: 'snils',
                maxLength: 11,
              ),
              
              // Полис ОМС
              _buildField(
                label: 'Полис ОМС',
                valueKey: 'oms',
                maxLength: 16,
              ),
              
              // Паспорт (серия и номер)
              _buildPassportFields(),
              
              SectionHeader(title: 'Контактная информация'),
              
              // Телефон
              _buildField(
                label: 'Телефон',
                valueKey: 'phone',
                keyboardType: TextInputType.phone,
              ),
              
              // Email
              _buildField(
                label: 'Email',
                valueKey: 'email',
                keyboardType: TextInputType.emailAddress,
              ),
              
              // Адрес
              _buildField(
                label: 'Адрес',
                valueKey: 'address',
                maxLines: 2,
              ),
              
              SectionHeader(title: 'Медицинская информация'),
              
              // Диагноз (только просмотр)
              ListTile(
                title: Text('Диагноз', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(widget.patient['diagnosis'] ?? 'Не указан'),
              ),
              
              // Противопоказания
              _buildField(
                label: 'Противопоказания',
                valueKey: 'contraindications',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String valueKey,
    bool isRequired = false,
    int? maxLength,
    int? maxLines,
    TextInputType? keyboardType,
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
            )
          : ListTile(
              title: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(
                widget.patient[valueKey]?.isNotEmpty == true
                    ? widget.patient[valueKey]
                    : 'Не указано',
              ),
            ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _isEditing
          ? DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Пол',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              value: widget.patient['gender'],
              items: const [
                DropdownMenuItem(value: 'Мужской', child: Text('Мужской')),
                DropdownMenuItem(value: 'Женский', child: Text('Женский')),
              ],
              onChanged: (value) {
                setState(() {
                  widget.patient['gender'] = value;
                });
              },
            )
          : ListTile(
              title: Text('Пол', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(widget.patient['gender'] ?? 'Не указан'),
            ),
    );
  }

  Widget _buildBirthDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _isEditing
          ? Row(
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    'Дата рождения',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DatePickerIconButton(
                  initialDate: widget.patient['birthDate'] != null
                      ? DateFormat('dd.MM.yyyy').parse(widget.patient['birthDate']!)
                      : null,
                  onDateSelected: (date) {
                    setState(() {
                      widget.patient['birthDate'] = DateFormat('dd.MM.yyyy').format(date);
                    });
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  widget.patient['birthDate'] ?? 'Дата не выбрана',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            )
          : ListTile(
              title: Text('Дата рождения', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(widget.patient['birthDate'] ?? 'Не указана'),
            ),
    );
  }

  Widget _buildPassportFields() {
    return _isEditing
        ? Row(
            children: [
              Expanded(
                child: CustomFormField(
                  label: 'Серия паспорта',
                  controller: _controllers['passportSeries']!,
                  maxLength: 4,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomFormField(
                  label: 'Номер паспорта',
                  controller: _controllers['passportNumber']!,
                  maxLength: 6,
                ),
              ),
            ],
          )
        : Column(
            children: [
              ListTile(
                title: Text('Серия паспорта', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(widget.patient['passportSeries'] ?? 'Не указана'),
              ),
              ListTile(
                title: Text('Номер паспорта', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(widget.patient['passportNumber'] ?? 'Не указан'),
              ),
            ],
          );
  }

  void _toggleEditMode() {
    if (_isEditing) {
      if (_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Изменения сохранены'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      }
    } else {
      setState(() => _isEditing = true);
    }
  }
}