import 'dart:typed_data';

import 'package:demo_app/presentation/pages/pdf_sign_screen.dart';
import 'package:demo_app/presentation/pages/pdf_view_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import 'package:provider/provider.dart';
import '../../services/pdf_service.dart';
import 'consultation_screen.dart';
import 'patient_detail_screen.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_chip.dart';
import 'package:signature/signature.dart';

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
        firstName: _firstNameController.text,
        middleName: _middleNameController.text,
        lastName: _lastNameController.text,
        birthDate: _birthDate!,
        isMale: _isMale!,
      );

      final patientId = response['data']['patient_id'] as int?;
      final receptionId = response['data']['id'] as int?;

      print("recepID от респона ${receptionId}");

      if (patientId == null || receptionId == null) {
        throw Exception('Не удалось получить ID созданного пациента или заключения');
      }
      // final fullName = '${_firstNameController.text ?? ''} ${ _lastNameController.text ?? ''} ${_middleNameController.text ?? ''}'.trim();

      final newPatient = {
        'id': receptionId,        // ID заключения (reception)
        'patientId': patientId,   // ID пациента
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'middleName': _middleNameController.text,
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
            children: [
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Фамилия',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите фамилию' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите имя' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _middleNameController,
                decoration: const InputDecoration(
                  labelText: 'Отчество',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите Отчество' : null,
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Пол:'),
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
          onPressed: _savePatient,
          child: const Text('Сохранить'),
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
    final fullName =
        '${patient['lastName'] ?? ''} ${patient['firstName'] ?? ''} ${patient['middleName'] ?? ''}'.trim();
    final birthDate = patient['birth_date'] != null
        ? DateFormat('dd.MM.yyyy').format(DateTime.parse(patient['birth_date']))
        : '';
    final age = patient['birth_date'] != null
        ? DateTime.now().year - DateTime.parse(patient['birth_date']).year
        : '';

    final pdfService = PdfService();
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    return DefaultTabController(
      length: 2,
      child: CustomCard(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Левая колонка
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fullName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Дата рождения: $birthDate'),
                    Text('Возраст: $age лет'),
                    if (patient['is_male'] != null)
                      Text(patient['is_male'] ? 'Мужской' : 'Женский'),
                    const SizedBox(height: 8),
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
              ),

              const SizedBox(width: 12),

              // Правая колонка с табами
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: "Прививки"),
                        Tab(text: "Согласие"),
                      ],
                    ),
                    SizedBox(
                      height: 180,
                      child: TabBarView(
                        children: [
                          // Прививки
                          Center(
                            child: Text(
                              "Прививки: пока пусто",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),

                          // Согласие
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Кнопка открыть PDF
                              Flexible(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final buttonWidth = constraints.maxWidth * 0.45;
                                    return SizedBox(
                                      width: buttonWidth.clamp(100, 200),
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                                        label: const Text('Открыть PDF', textAlign: TextAlign.center),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        onPressed: () async {
                                          try {
                                            // final receptionId = patient['receptionId']?.toString();
                                            // final patientSignatureBase64 = await apiClient.getPatientSignature(receptionId!);
                                            // pdfService.downloadSignature(patientSignatureBase64!);

                                            final pdfFile = await pdfService.generateFullPatientAgreementWithBackendSignature(
                                              fullName: fullName,
                                              address: patient['address'] ?? 'не указано',
                                              receptionId: patient['receptionId'].toString(),
                                              apiClient: apiClient,
                                            );
                                            // Получаем байты PDF
                                            Uint8List pdfBytes;
                                            if (kIsWeb) {
                                              // На вебе pdfFile будет null, поэтому открываем PDF через Blob
                                              await pdfService.openPdf(pdfFile);
                                              // Если тебе нужны байты для PdfViewerScreen на вебе, нужно изменить метод генерации PDF
                                              // чтобы он возвращал Uint8List на вебе
                                              pdfBytes = await pdfFile!.readAsBytes(); 
                                            } else {
                                              // Мобильные/десктопные платформы
                                              pdfBytes = await pdfFile!.readAsBytes(); // ! безопасно, т.к. на мобильных pdfFile не null
                                            }

                                            // Открываем экран с PDF
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PdfViewerScreen(pdfBytes: pdfBytes),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Ошибка генерации PDF: $e')),
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Кнопка подписать
                              Flexible(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final buttonWidth = constraints.maxWidth * 0.45;
                                    return SizedBox(
                                      width: buttonWidth.clamp(100, 200),
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.edit, size: 18),
                                        label: const Text('Подписать', textAlign: TextAlign.center),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final receptionId = patient['receptionId']?.toString();
                                          if (receptionId != null) {
                                            try {

                                              // открываем экран подписи
                                              final signatureBytes = await Navigator.push<Uint8List>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => PdfSignatureScreen(
                                                    receptionId: receptionId,
                                                  ),
                                                ),
                                              );

                                              if (signatureBytes != null) {

                                                // можно сразу сохранить на сервер через API
                                                await apiClient.uploadReceptionSignature(
                                                  receptionId: receptionId,
                                                  signatureBytes: signatureBytes
                                                  );

                                                // обновляем экран
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Подпись добавлена')),
                                                );
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Ошибка подписи: $e')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    );
                                  },
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

              // Кнопка заключения справа
              IconButton(
                icon: const Icon(Icons.note_alt, color: Colors.blue),
                tooltip: "Заключение",
                onPressed: () => _startConsultation(patient),
              ),
            ],
          ),
        ),
      ),
    );
  }




  void _startConsultation(Map<String, dynamic> patient) {
    final fullName = '${patient['lastName'] ?? ''} ${patient['firstName'] ?? ''} ${patient['middleName'] ?? ''}'.trim();
    print('Открываем ConsultationScreen с patientId=${patient['id']}, emergencyCallId=${widget.call['id']}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationScreen(
          patientName: fullName,
          appointmentType: 'emergency',
          recordId: patient['receptionId'], 
          doctorId: Provider.of<ApiClient>(context, listen: false).currentDoctorId ?? 1,
          emergencyCallId: widget.call['id'], // callId
        ),
      ),
    ).then((result) {
      if (result == true) {
        // _loadCallDetails();
        setState(() {
        patient['hasConclusion'] = true;
        });
        _updateCallStatusIfCompleted();
      }
    });
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

  void _openConsentDocument(Map<String, dynamic> patient) {
    final receptionId = patient['receptionId']?.toString(); // <-- используем правильный ключ
    print('ReceptionId: $receptionId'); // для проверки
    if (receptionId == null) return;

    // Navigator.push(
      // context,
      // MaterialPageRoute(
        // builder: (context) => PdfViewerScreen(receptionId: receptionId),
      // ),
    // );
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

  void _showPatientOptions(Map<String, dynamic> patient) {
    final fullName = '${patient['lastName'] ?? ''} ${patient['firstName'] ?? ''} ${patient['middleName'] ?? ''}'.trim();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(fullName),
        content: const Text('Выберите действие'),
        actions: [
          // Оставляем только кнопку для начала обследования (если не завершено)
          if (!patient['hasConclusion'])
            TextButton(
              child: const Text('Согласие на осмотр'),
              onPressed: () {
                Navigator.pop(context);
                _openConsentDocument(patient);
              },
            ),
            TextButton(
              child: const Text('Начать обследование'),
              onPressed: () {
                Navigator.pop(context);
                _startConsultation(patient);
              },
            ),
            if (patient['hasConclusion'])
          TextButton(
            child: const Text('Редактировать заключение'),
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

}