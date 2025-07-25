import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import 'package:provider/provider.dart';
import 'consultation_screen.dart';
import 'patient_detail_screen.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_chip.dart';

class CallDetailScreen extends StatefulWidget {
  final Map<String, dynamic> call;

  const CallDetailScreen({super.key, required this.call});

  @override
  State<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _AddPatientDialog extends StatefulWidget {
  final int emergencyCallId;
  final String patientPhone; // Добавляем телефон
  final Function(Map<String, dynamic>) onPatientCreated;

  const _AddPatientDialog({
    required this.emergencyCallId,
    required this.patientPhone, // Принимаем телефон
    required this.onPatientCreated,
  });

  @override
  State<_AddPatientDialog> createState() => __AddPatientDialogState();
}

class __AddPatientDialogState extends State<_AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  bool? _isMale;
  bool _isSaving = false;

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null || _isMale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final response = await apiClient.createEmergencyReceptionPatient(
        emergencyCallId: widget.emergencyCallId,
        fullName: _nameController.text,
        birthDate: _birthDate!,
        isMale: _isMale!,
      );

      final patientId = response['data']['patient_id'] as int?;
      final receptionId = response['data']['id'] as int?;

      if (patientId == null || receptionId == null) {
        throw Exception('Не удалось получить ID созданного пациента или заключения');
      }

      final newPatient = {
        'id': receptionId,        // ID заключения (reception)
        'patientId': patientId,   // ID пациента
        'name': _nameController.text,
        'birthDate': _birthDate,
        'isMale': _isMale,
        'hasConclusion': false,
        'phone': widget.patientPhone,
      };

      widget.onPatientCreated(newPatient);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить пациента'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ФИО',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите ФИО пациента';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Дата рождения:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DatePickerIconButton(
                      initialDate: _birthDate,
                      onDateSelected: (date) => setState(() => _birthDate = date),
                      showDateText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Пол:'),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: _isMale,
                    onChanged: (value) => setState(() => _isMale = value),
                  ),
                  const Text('Мужской'),
                  Radio<bool>(
                    value: false,
                    groupValue: _isMale,
                    onChanged: (value) => setState(() => _isMale = value),
                  ),
                  const Text('Женский'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _savePatient,
          child: _isSaving 
              ? const CircularProgressIndicator()
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _callDetails;

  @override
  void initState() {
    super.initState();
    _loadCallDetails();
  }

  Future<void> _loadCallDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final response = await apiClient.getEmergencyCallDetails(widget.call['id'].toString());

      // Получаем данные пациентов из data->hits
      final patientsData = response['data']['hits'] as List<dynamic>;

      setState(() {
        _callDetails = response;
        widget.call['patients'] = _transformPatientsData(patientsData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки деталей вызова: $e';
        _isLoading = false;
      });
    }
  }

  

  List<Map<String, dynamic>> _transformPatientsData(List<dynamic> patientsData) {
    return patientsData.map((patient) {
      return {
        'id': patient['id'],
        'patientId': patient['patient']['id'],
        'name': patient['patient']['full_name'] ?? 'Пациент ${patient['id']}',
        'hasConclusion': false,
        'diagnosis': patient['diagnosis'] ?? '',
        'recommendations': patient['recommendations'] ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayCall = _callDetails != null 
        ? {...widget.call, ..._callDetails!} 
        : widget.call;
    final patients = widget.call['patients'] as List<dynamic>;
    final completedCount = patients
        .where((patient) => patient['hasConclusion'] == true)
        .length;
    final totalPatients = patients.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Вызов #${widget.call['id']}'),
        actions: [
          if (completedCount == totalPatients)
            Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusChip(
                        text: widget.call['status'],
                        isEmergency: widget.call['status'] == 'ЭКСТРЕННЫЙ',
                      ),
                      Text(
                        widget.call['time'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Адрес: ${widget.call['address']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Телефон: ${widget.call['phone']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Пациенты: $completedCount/$totalPatients завершено',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Пациенты:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return _buildPatientCard(patient);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Добавить пациента'),
                  onPressed: _addPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          patient['hasConclusion'] ? Icons.check_circle : Icons.person,
          color: patient['hasConclusion'] ? Colors.green : Theme.of(context).primaryColor,
          size: 32,
        ),
        title: Text(
          patient['name'] ?? 'Новый пациент',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (patient['birthDate'] != null)
              Text('ДР: ${DateFormat('dd.MM.yyyy').format(patient['birthDate'])}'),
            if (patient['isMale'] != null)
              Text(patient['isMale'] ? 'Мужской' : 'Женский'),
            const SizedBox(height: 4),
            Text(
              patient['hasConclusion'] 
                  ? 'Обследование завершено' 
                  : 'Требуется обследование',
              style: TextStyle(
                color: patient['hasConclusion'] ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        trailing: patient['hasConclusion']
            ? null
            : ElevatedButton(
                child: const Text('Заключение'),
                onPressed: () => _startConsultation(patient),
              ),
        onTap: () => _showPatientOptions(patient),
      ),
    );
  }

  void _startConsultation(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationScreen(
          patientName: patient['name'],
          appointmentType: 'emergency',
          recordId: patient['patientId'], // Используем patientId как smpId
          doctorId: Provider.of<ApiClient>(context, listen: false).currentDoctorId ?? 1,
          emergencyCallId: widget.call['id'], // callId
        ),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          patient['hasConclusion'] = true;
        });
        _updateCallStatusIfCompleted();
      }
    });
  }

  void _checkCallCompletion() {
    final allCompleted = widget.call['patients']
        .every((patient) => patient['hasConclusion'] == true);
    if (allCompleted) {
      setState(() {
        widget.call['isCompleted'] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Вызов завершен!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _addPatient() {
    showDialog(
      context: context,
      builder: (context) => _AddPatientDialog(
        emergencyCallId: widget.call['id'],
        patientPhone: widget.call['phone'] ?? 'Телефон не указан', // Передаем телефон напрямую
        onPatientCreated: (newPatient) {
          setState(() {
            widget.call['patients'].add(newPatient);
          });
          _updateCallStatusIfCompleted();
        },
      ),
    );
  }

  void _updateCallStatusIfCompleted() async {
    final allCompleted = widget.call['patients']
        .every((patient) => patient['hasConclusion'] == true);
        
    if (allCompleted) {
      try {
        final apiClient = Provider.of<ApiClient>(context, listen: false);
        await apiClient.updateEmergencyCallStatus(
          widget.call['id'].toString(),
          'completed'
        );
        
        setState(() {
          widget.call['isCompleted'] = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вызов успешно завершен!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления статуса вызова: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPatientOptions(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(patient['name']),
        content: const Text('Выберите действие'),
        actions: [
          // УДАЛЕНА КНОПКА "Карта пациента"

          // Оставляем только кнопку для начала обследования (если не завершено)
          if (!patient['hasConclusion'])
            TextButton(
              child: const Text('Начать обследование'),
              onPressed: () {
                Navigator.pop(context);
                _startConsultation(patient);
              },
            ),
          TextButton(
            child: const Text('Закрыть'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _openPatientDetails(Map<String, dynamic> patient) {
    final patientData = {
      'id': patient['id'],
      'fullName': patient['name'],
      'address': widget.call['address'],
      'phone': '+7 (XXX) XXX-XX-XX',
      'diagnosis': 'Экстренный вызов',
      'room': 'Не госпитализирован',
      'gender': 'Мужской',
      'birthDate': '01.01.1980',
      'snils': '123-456-789 00',
      'oms': '1234567890123456',
      'passport': '1234 567890',
      'email': 'patient@example.com',
      'contraindications': 'Нет',
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patientId: patientData['id']),
      ),
    );
  }
}