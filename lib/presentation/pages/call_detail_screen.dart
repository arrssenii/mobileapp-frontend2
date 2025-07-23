import 'package:flutter/material.dart';
import 'consultation_screen.dart';
import 'patient_detail_screen.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_chip.dart';

class CallDetailScreen extends StatefulWidget {
  final Map<String, dynamic> call;

  const CallDetailScreen({super.key, required this.call});

  @override
  State<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  @override
  Widget build(BuildContext context) {
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
          'Пациент ${patient['id']}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Телефон: ${patient['phone']}'),
            const SizedBox(height: 4),
            Text(
              patient['hasConclusion'] 
                  ? 'Консультация завершена' 
                  : 'Требуется консультация',
              style: TextStyle(
                color: patient['hasConclusion'] ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        trailing: patient['hasConclusion']
            ? null
            : ElevatedButton(
                child: const Text('Консультация'),
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
          appointmentType: 'call',
          recordId: patient['id'],
          specialization: 'Терапевт',
        ),
      ),
    ).then((result) {
      if (result != null && result == true) {
        setState(() {
          patient['hasConclusion'] = true;
          _checkCallCompletion();
        });
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
    final newPatientId = DateTime.now().millisecondsSinceEpoch;
    final newPatient = {
      'id': newPatientId,
      'name': 'Новый пациент #${widget.call['patients'].length + 1}',
      'hasConclusion': false,
    };

    setState(() {
      widget.call['patients'].add(newPatient);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Пациент добавлен в вызов'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPatientOptions(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(patient['name']),
        content: const Text('Выберите действие'),
        actions: [
          TextButton(
            child: const Text('Карта пациента'),
            onPressed: () {
              Navigator.pop(context);
              _openPatientDetails(patient);
            },
          ),
          if (!patient['hasConclusion'])
            TextButton(
              child: const Text('Начать консультацию'),
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