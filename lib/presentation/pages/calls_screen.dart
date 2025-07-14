import 'package:flutter/material.dart';
import './patient_detail_screen.dart';
import './call_detail_screen.dart';
import 'consultation_screen.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_chip.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  List<Map<String, dynamic>> _calls = [];
  List<Map<String, dynamic>> _filteredCalls = [];

  @override
  void initState() {
    super.initState();
    _loadCalls();
  }

  void _loadCalls() {
    // Фиктивные данные вызовов с несколькими пациентами
    _calls = [
      {
        'id': 1,
        'address': 'ул. Ленина, д. 15, кв. 42',
        'status': 'ЭКСТРЕННЫЙ',
        'time': '10:30',
        'doctor': 'Иванова М.П.',
        'patients': [
          {
            'id': 101,
            'name': 'Смирнов Александр Петрович',
            'hasConclusion': false,
          },
          {
            'id': 102,
            'name': 'Иванова Мария Сергеевна',
            'hasConclusion': false,
          }
        ],
        'isCompleted': false,
      },
      {
        'id': 2,
        'address': 'пр. Победы, д. 87, кв. 12',
        'status': 'НЕОТЛОЖНЫЙ',
        'time': '11:15',
        'doctor': 'Петров А.В.',
        'patients': [
          {
            'id': 201,
            'name': 'Козлова Ольга Ивановна',
            'hasConclusion': false,
          }
        ],
        'isCompleted': false,
      },
      {
        'id': 3,
        'address': 'ул. Садовая, д. 5, кв. 34',
        'status': 'ЭКСТРЕННЫЙ',
        'time': '12:40',
        'doctor': 'Сидорова Е.К.',
        'patients': [
          {
            'id': 301,
            'name': 'Васильев Дмитрий Сергеевич',
            'hasConclusion': false,
          },
          {
            'id': 302,
            'name': 'Петрова Анна Михайловна',
            'hasConclusion': false,
          },
          {
            'id': 303,
            'name': 'Соколов Игорь Викторович',
            'hasConclusion': false,
          }
        ],
        'isCompleted': false,
      },
      {
        'id': 4,
        'address': 'пр. Строителей, д. 23, кв. 7',
        'status': 'НЕОТЛОЖНЫЙ',
        'time': '13:20',
        'doctor': 'Фёдоров И.Д.',
        'patients': [
          {
            'id': 401,
            'name': 'Никитина Елена Владимировна',
            'hasConclusion': false,
          },
          {
            'id': 402,
            'name': 'Фёдоров Артём Игоревич',
            'hasConclusion': false,
          }
        ],
        'isCompleted': false,
      },
      {
        'id': 5,
        'address': 'ул. Центральная, д. 1, кв. 89',
        'status': 'ЭКСТРЕННЫЙ',
        'time': '14:50',
        'doctor': 'Иванова М.П.',
        'patients': [
          {
            'id': 501,
            'name': 'Горбачёв Михаил Юрьевич',
            'hasConclusion': false,
          },
          {
            'id': 502,
            'name': 'Кузнецова Ольга Сергеевна',
            'hasConclusion': false,
          }
        ],
        'isCompleted': false,
      },
      {
        'id': 6,
        'address': 'пр. Космонавтов, д. 45, кв. 3',
        'status': 'НЕОТЛОЖНЫЙ',
        'time': '15:30',
        'doctor': 'Семёнов В.К.',
        'patients': [
          {
            'id': 601,
            'name': 'Павлов Иван Николаевич',
            'hasConclusion': false,
          }
        ],
        'isCompleted': false,
      },
      {
        'id': 7,
        'address': 'ул. Парковая, д. 12, кв. 7',
        'status': 'ЭКСТРЕННЫЙ',
        'time': '16:10',
        'doctor': 'Иванова М.П.',
        'patients': [
          {
            'id': 701,
            'name': 'Степанова Екатерина Викторовна',
            'hasConclusion': false,
          },
          {
            'id': 702,
            'name': 'Степанов Алексей Дмитриевич',
            'hasConclusion': false,
          }
        ],
        'isCompleted': false,
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

  void _openCallDetails(BuildContext context, Map<String, dynamic> call) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallDetailScreen(call: call),
      ),
    ).then((_) {
      setState(() {});
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFFFFF), // Перенесено в правильное место
      title: Text(
        'Вызовы',
        style: TextStyle(color: Color(0xFF8B8B8B)),
      ), // Добавлена закрывающая скобка для Text
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
    final isCompleted = call['isCompleted'];
    final completedCount = call['patients'].where((p) => p['hasConclusion'] == true).length;
    final totalPatients = call['patients'].length;

    return GestureDetector(
      onTap: () => _openCallDetails(context, call),
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
                '${call['address']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.person_outline, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Пациенты: $completedCount/$totalPatients завершено',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.local_hospital, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Врач: ${call['doctor']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}