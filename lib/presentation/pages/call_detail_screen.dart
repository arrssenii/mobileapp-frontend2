import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import 'package:provider/provider.dart';
import 'consultation_screen.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_chip.dart';
import '../widgets/patient_card_widget.dart';

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
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _secondPhoneController = TextEditingController();
  final _snilsController = TextEditingController();
  final _documentSeriesController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _omsPolicyController = TextEditingController();
  final _emailController = TextEditingController();
  final _allergyController = TextEditingController();
  
  DateTime? _birthDate;
  bool? _isMale;
  String? _documentType;
  bool _isSaving = false;

  final List<String> _documentTypes = [
    'Паспорт РФ',
    'Заграничный паспорт',
    'Водительское удостоверение',
    'Свидетельство о рождении',
    'Военный билет',
    'Иной документ'
  ];

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null || _isMale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните обязательные поля')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      

      final response = await apiClient.createEmergencyReceptionPatient(
        emergencyCallId: widget.emergencyCallId,
        firstName: _firstNameController.text,
        middleName: _middleNameController.text,
        lastName: _lastNameController.text,
        birthDate: _birthDate!,
        isMale: _isMale!,
      );

      final patientId = response['data']['patient_id'] as int?;
      final receptionId = response['data']['id'] as int?;

      // print("recepID от респона ${receptionId}");

      if (patientId == null || receptionId == null) {
        throw Exception('Не удалось получить ID созданного пациента или заключения');
      }

      final newPatient = {
        'id': receptionId,        // ID заключения (reception)
        'patientId': patientId,   // ID пациента
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'middleName': _middleNameController.text,
        'birthDate': _birthDate,
        'isMale': _isMale,
        'hasConclusion': false,
        'phone': _phoneController.text.isNotEmpty ? _phoneController.text : widget.patientPhone,
        'secondPhone': _secondPhoneController.text,
        'snils': _snilsController.text,
        'documentType': _documentType,
        'documentSeries': _documentSeriesController.text,
        'documentNumber': _documentNumberController.text,
        'address': _addressController.text,
        'omsPolicy': _omsPolicyController.text,
        'email': _emailController.text,
        'allergy': _allergyController.text,
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
            children: [
              // Основные данные
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Фамилия *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите фамилию' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Имя *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите имя' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _middleNameController,
                decoration: const InputDecoration(
                  labelText: 'Отчество *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите отчество' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Дата рождения *:'),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Пол *:'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<bool>(
                      value: _isMale,
                      isExpanded: true,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _isMale = value;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Мужской')),
                        DropdownMenuItem(value: false, child: Text('Женский')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Контактные данные
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Номер телефона',
                  hintText: widget.patientPhone,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _secondPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Второй номер телефона',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Адрес',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              
              // Документы
              TextFormField(
                controller: _snilsController,
                decoration: const InputDecoration(
                  labelText: 'СНИЛС',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Тип документа:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _documentType,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _documentType = value;
                        });
                      },
                      items: _documentTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _documentSeriesController,
                      decoration: const InputDecoration(
                        labelText: 'Серия документа',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _documentNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Номер документа',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _omsPolicyController,
                decoration: const InputDecoration(
                  labelText: 'Полис ОМС',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              
              // Медицинская информация
              TextFormField(
                controller: _allergyController,
                decoration: const InputDecoration(
                  labelText: 'Аллергия',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              
              const Text(
                '* - обязательные поля',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _savePatient,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCallDetails();
  }

  Future<void> _loadCallDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final response = await apiClient.getEmergencyCallDetails(widget.call['id'].toString());

      // Получаем данные пациентов из data->hits
      final patientsData = response['data']['hits'] as List<dynamic>;

      setState(() {
        widget.call['patients'] = _transformPatientsData(patientsData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки деталей вызова: $e')),
      );
    }
  }

  

  List<Map<String, dynamic>> _transformPatientsData(List<dynamic> patientsData) {
      return patientsData.map<Map<String, dynamic>>((item) {
        final data = item['patient'] ?? item;
        final hasConclusion = (item['diagnosis'] != null && 
                         (item['diagnosis'] as String).isNotEmpty) ||
                        (item['recommendations'] != null && 
                         (item['recommendations'] as String).isNotEmpty);
        return {
          'firstName': data['first_name'] ?? data['firstName'] ?? '',
          'lastName': data['last_name'] ?? data['lastName'] ?? '',
          'middleName': data['middle_name'] ?? data['middleName'] ?? '',
          'birth_date': data['birth_date'],
          'is_male': data['is_male'],
          'patientId': data['id'], // ID пациента
          'receptionId': item['id'], // ID приёма (smpId) <-- ДОБАВЬТЕ ЭТО!
          'hasConclusion': hasConclusion,
          // добавь другие нужные поля
        };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // final displayCall = _callDetails != null
    //     ? {...widget.call, ..._callDetails!}
    //     : widget.call;
    final patients = widget.call['patients'] as List<dynamic>;
    final completedCount = patients
        .where((patient) => patient['hasConclusion'] == true)
        .length;
    final totalPatients = patients.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Вызов #${widget.call['id']}'),
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
                        text: widget.call['mainStatus'],
                        isEmergency: widget.call['mainStatus'] == 'ЭКСТРЕННЫЙ',
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
    return PatientCardWidget(
      patient: patient,
      emergencyCallId: widget.call['id'],
      onPatientUpdated: _loadCallDetails,
      onCallCompleted: _updateCallStatusIfCompleted,
    );
  }






  void _addPatient() {
    showDialog(
      context: context,
      builder: (context) => _AddPatientDialog(
        emergencyCallId: widget.call['id'],
        patientPhone: widget.call['phone'] ?? 'Телефон не указан', // Передаем телефон напрямую
        
        onPatientCreated: (newPatient) {
          _loadCallDetails();
          // print('Карточка пациента: $newPatient');

          // setState(() {
          //   widget.call['patients'].add(newPatient);
          // });
          // _updateCallStatusIfCompleted();
        },
      ),
    );
  }



  void _updateCallStatusIfCompleted() async {
    // await _loadCallDetails();
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



}