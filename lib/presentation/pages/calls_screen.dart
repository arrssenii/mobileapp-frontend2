import 'package:flutter/material.dart';
import './patient_detail_screen.dart';
import 'consultation_screen.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_chip.dart';
import '../widgets/call_option_dialog.dart';
import '../widgets/action_tile.dart';
import '../widgets/detail_row.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  List<Map<String, dynamic>> _calls = [];
  List<Map<String, dynamic>> _filteredCalls = [];
  Set<int> _completedCalls = Set();

  @override
  void initState() {
    super.initState();
    _loadCalls();
  }

  void _loadCalls() {
    // Фиктивные данные вызовов
    _calls = [
      {
        'id': 1,
        'patientName': 'Смирнов Александр Петрович',
        'address': 'ул. Ленина, д. 15, кв. 42',
        'status': 'ЭКСТРЕННЫЙ',
        'time': '10:30',
        'doctor': 'Иванова М.П.',
      },
      {
        'id': 2,
        'patientName': 'Козлова Ольга Ивановна',
        'address': 'пр. Победы, д. 87, кв. 12',
        'status': 'НЕОТЛОЖНЫЙ',
        'time': '11:15',
        'doctor': 'Петров А.В.',
      },
      {
        'id': 3,
        'patientName': 'Васильев Дмитрий Сергеевич',
        'address': 'ул. Садовая, д. 5, кв. 34',
        'status': 'ЭКСТРЕННЫЙ',
        'time': '12:40',
        'doctor': 'Сидорова Е.К.',
      },
      {
        'id': 4,
        'patientName': 'Никитина Елена Владимировна',
        'address': 'пр. Строителей, д. 23, кв. 7',
        'status': 'НЕОТЛОЖНЫЙ',
        'time': '13:20',
        'doctor': 'Фёдоров И.Д.',
      },
      {
        'id': 5,
        'patientName': 'Горбачёв Михаил Юрьевич',
        'address': 'ул. Центральная, д. 1, кв. 89',
        'status': 'ЭКСТРЕННЫЙ',
        'time': '14:50',
        'doctor': 'Иванова М.П.',
      },
    ];
    
    // Сортируем: сначала экстренные, затем по времени
    _filteredCalls = List.from(_calls)
      ..sort((a, b) {
        if (a['status'] == 'ЭКСТРЕННЫЙ' && b['status'] != 'ЭКСТРЕННЫЙ') {
          return -1;
        } else if (a['status'] != 'ЭКСТРЕННЫЙ' && b['status'] == 'ЭКСТРЕННЫЙ') {
          return 1;
        }
        return a['time'].compareTo(b['time']);
      });
  }

  void _refreshCalls() {
    setState(() {
      _loadCalls();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Список вызовов обновлён')),
      );
    });
  }

  void _startCallConsultation(Map<String, dynamic> call) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ConsultationScreen(
        patientName: call['patientName'],
        appointmentType: 'call',
        recordId: call['id'],
      ),
    ),
  ).then((result) {
    if (result != null) {
      setState(() {
        _completedCalls.add(call['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Заключение по вызову ${call['patientName']} сохранено'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  });
}

// Обновим _showCallOptions
void _showCallOptions(BuildContext context, Map<String, dynamic> call) {
  showDialog(
    context: context,
    builder: (context) {
      return CallOptionDialog(
        call: call,
        isCompleted: _completedCalls.contains(call['id']),
        onAccept: () {
          Navigator.pop(context);
          _startCallConsultation(call);
        },
        onDetails: () {
          Navigator.pop(context);
          _showCallDetails(context, call);
        },
        onPatient: () {
          Navigator.pop(context);
          _openPatientDetails(context, call);
        },
        onCancel: () {
          setState(() {
            _completedCalls.add(call['id']);
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Вызов ${call['patientName']} отменен'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      );
    },
  );
}

// Обновим _showCallDetails
void _showCallDetails(BuildContext context, Map<String, dynamic> call) {
  showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: AlertDialog(
            title: Text(
              'Детали вызова',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DetailRow(label: 'Пациент', value: call['patientName']),
                  DetailRow(label: 'Адрес', value: call['address']),
                  DetailRow(label: 'Время', value: call['time']),
                  DetailRow(label: 'Статус', value: call['status']),
                  DetailRow(label: 'Лечащий врач', value: call['doctor']),
                  const SizedBox(height: 10),
                  Text('Примечания:', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  )),
                  const Text('Пациент сообщил о сильных болях в груди'),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Закрыть'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _openPatientDetails(BuildContext context, Map<String, dynamic> call) {
  // В реальном приложении здесь будет запрос данных пациента
  // Сейчас используем фиктивные данные
  final patient = {
    'id': call['id'],
    'fullName': call['patientName'],
    'room': 'Не госпитализирован',
    'diagnosis': 'Экстренный вызов',
    'phone': '+7 (XXX) XXX-XX-XX',
    'address': call['address'],
  };
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PatientDetailScreen(patient: patient),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Вызовы',
            style: TextStyle(color: Color(0xFF8B8B8B)),
          ),
          backgroundColor: const Color(0xFFFFFFFF),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshCalls,
              tooltip: 'Обновить список',
              color: Color(0xFF8B8B8B),
            ),
          ],
        ),
      body: ListView.builder(
        itemCount: _filteredCalls.length,
        itemBuilder: (context, index) {
          final call = _filteredCalls[index];
          return _buildCallCard(call);
        },
      ),
    );
  }

  Widget _buildCallCard(Map<String, dynamic> call) {
  final isEmergency = call['status'] == 'ЭКСТРЕННЫЙ';
  final isCompleted = _completedCalls.contains(call['id']);
  
  return GestureDetector(
    onTap: () => _showCallOptions(context, call),
    child: CustomCard(
      backgroundColor: isCompleted 
          ? Colors.green[100] 
          : isEmergency 
              ? const Color(0xFFFFEBEE).withOpacity(0.7) 
              : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusChip(
                  text: call['status'],
                  isEmergency: isEmergency,
                ),
                Text(
                  call['time'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              call['patientName'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    call['address'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.person_outline, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Врач: ${call['doctor']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            
            // УДАЛЕНО: Кнопки действий
          ],
        ),
      ),
    ),
  );
}
}