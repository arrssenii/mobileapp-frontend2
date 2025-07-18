import 'package:flutter/material.dart';
import './call_detail_screen.dart';
import '../widgets/responsive_card_list.dart';
import '../widgets/date_carousel.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _calls = [];
  List<Map<String, dynamic>> _filteredCalls = [];

  Future<void> _refreshCalls() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loadCalls();
      _filterCallsByDate();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCalls();
    _filterCallsByDate();
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filterCallsByDate();
    });
  }

  void _filterCallsByDate() {
    _filteredCalls = _calls.where((call) {
      final callDate = call['date'] as DateTime;
      return callDate.year == _selectedDate.year &&
             callDate.month == _selectedDate.month &&
             callDate.day == _selectedDate.day;
    }).toList();
    
    _filteredCalls.sort((a, b) {
      if (a['status'] == 'ЭКСТРЕННЫЙ' && b['status'] != 'ЭКСТРЕННЫЙ') {
        return -1;
      } else if (a['status'] != 'ЭКСТРЕННЫЙ' && b['status'] == 'ЭКСТРЕННЫЙ') {
        return 1;
      }
      return a['time'].compareTo(b['time']);
    });
  }

  void _loadCalls() {
    final today = DateTime.now();
    
    _calls = [
      {
        'id': 1,
        'date': today,
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
        'date': today,
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
        'date': today.add(const Duration(days: 1)),
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
        'date': today.add(const Duration(days: -1)),
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
        'date': today,
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
        'date': today.add(const Duration(days: 1)),
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
        'date': today,
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
      {
        'id': 8,
        'date': today.add(const Duration(days: 2)),
        'address': 'ул. Новая, д. 25, кв. 14',
        'status': 'ЭКСТРЕННЫЙ',
        'time': '09:15',
        'doctor': 'Петров А.В.',
        'patients': [
          {
            'id': 801,
            'name': 'Ковалёв Денис Олегович',
            'hasConclusion': false,
          }
        ],
        'isCompleted': false,
      },
      {
        'id': 9,
        'date': today.add(const Duration(days: -2)),
        'address': 'пр. Мира, д. 56, кв. 22',
        'status': 'НЕОТЛОЖНЫЙ',
        'time': '17:45',
        'doctor': 'Сидорова Е.К.',
        'patients': [
          {
            'id': 901,
            'name': 'Орлова Виктория Александровна',
            'hasConclusion': false,
          },
          {
            'id': 902,
            'name': 'Белов Артём Сергеевич',
            'hasConclusion': false,
          }
        ],
        'isCompleted': false,
      },
    ];
  }

  void _openCallDetails(dynamic callData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallDetailScreen(call: callData as Map<String, dynamic>),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: Text(
          'Вызовы',
          style: TextStyle(color: Color(0xFF8B8B8B)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCalls,
            tooltip: 'Обновить список',
            color: Color(0xFF8B8B8B),
          ),
        ],
      ),
      body: Column(
        children: [
          DateCarousel(
            initialDate: _selectedDate,
            onDateSelected: _handleDateSelected,
            daysRange: 30,
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Вызовы на ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Expanded(
            child: ResponsiveCardList(
              type: CardListType.calls,
              items: _filteredCalls,
              onItemTap: (context, item) => _openCallDetails(item),
              onRefresh: _refreshCalls,
            ),
          ),
        ],
      ),
    );
  }
}