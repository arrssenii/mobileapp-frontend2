import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _patientFuture = _loadPatient();
  }

  Future<Patient> _loadPatient() async {
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    return await apiClient.getMedCardByPatientId(widget.patientId);
  }

  void _initControllers(Patient patient) {
    _controllers['fullName'] = TextEditingController(text: patient.fullName);
    _controllers['phone'] = TextEditingController(text: patient.phone);
    _controllers['email'] = TextEditingController(text: patient.email);
    _controllers['address'] = TextEditingController(text: patient.address);
    _controllers['snils'] = TextEditingController(text: patient.snils);
    _controllers['oms'] = TextEditingController(text: patient.oms);
    _controllers['passport'] = TextEditingController(text: patient.passport);
    _controllers['contraindications'] = TextEditingController(
      text: patient.allergies.join(', ')
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
          if (!_controllers.containsKey('fullName')) {
            _initControllers(patient);
          }
          
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SectionHeader(title: 'Основная информация'),
                  
                  _buildField(
                    label: 'ФИО',
                    valueKey: 'fullName',
                    displayValue: patient.fullName,
                    isRequired: true,
                  ),
                  
                  ListTile(
                    title: const Text('Пол', 
                      style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(patient.gender),
                  ),
                  
                  ListTile(
                    title: const Text('Дата рождения', 
                      style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(patient.formattedBirthDate),
                  ),
                  
                  SectionHeader(title: 'Документы'),
                  
                  _buildField(
                    label: 'СНИЛС',
                    valueKey: 'snils',
                    displayValue: patient.snils,
                    maxLength: 11,
                  ),
                  
                  _buildField(
                    label: 'Полис ОМС',
                    valueKey: 'oms',
                    displayValue: patient.oms,
                    maxLength: 16,
                  ),
                  
                  _buildField(
                    label: 'Паспорт',
                    valueKey: 'passport',
                    displayValue: patient.passport,
                  ),
                  
                  SectionHeader(title: 'Контактная информация'),
                  
                  _buildField(
                    label: 'Телефон',
                    valueKey: 'phone',
                    displayValue: patient.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  
                  _buildField(
                    label: 'Email',
                    valueKey: 'email',
                    displayValue: patient.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  _buildField(
                    label: 'Адрес',
                    valueKey: 'address',
                    displayValue: patient.address,
                    maxLines: 2,
                  ),
                  
                  SectionHeader(title: 'Медицинская информация'),
                  
                  _buildField(
                    label: 'Аллергии и противопоказания',
                    valueKey: 'contraindications',
                    displayValue: patient.allergies.join(', '),
                    maxLines: 3,
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
              title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(displayValue.isEmpty ? 'Не указано' : displayValue),
            ),
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