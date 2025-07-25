import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCalls();
  }

  Future<void> _refreshCalls() async {
    await _loadCalls();
  }

  Future<void> _loadCalls() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final currentDoctor = apiClient.currentDoctor;

      if (currentDoctor == null) {
        throw Exception('Доктор не авторизован');
      }

      final docId = currentDoctor.id.toString();
      final response = await apiClient.getEmergencyCallsByDoctorAndDate(
        docId,
        date: _selectedDate,
      );

      // Получаем список вызовов из поля 'hits'
      final loadedCalls = _transformApiData(response['hits'] as List<dynamic>);

      setState(() {
        _calls = loadedCalls;
        _filterCallsByDate();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки вызовов: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _transformApiData(List<dynamic> apiData) {
    return apiData.map((call) {
      final createdAt = DateTime.parse(call['created_at']);
      final time = '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
      final status = call['emergency'] == true ? 'ЭКСТРЕННЫЙ' : 'НЕОТЛОЖНЫЙ';
  
      return {
        'id': call['id'],
        'date': createdAt,
        'address': call['address'] ?? 'Адрес не указан',
        'phone': call['phone'] ?? 'Телефон не указан',
        'status': status,
        'time': time,
        'isCompleted': false,
        'patients': [],
      };
    }).toList();
  }

List<Map<String, dynamic>> _getPatientsFromCall(Map<String, dynamic> call) {
  // Временное решение, пока нет данных о пациентах
  return [
    {
      'id': call['id'], // Используем ID вызова как временный ID пациента
      'name': 'Пациент: ${call['phone']}',
      'hasConclusion': false,
    }
  ];
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
      if (a['status'] == 'ЭКСТРЕННЫЙ' && b['status'] != 'ЭКСТРЕННЫЙ') return -1;
      if (a['status'] != 'ЭКСТРЕННЫЙ' && b['status'] == 'ЭКСТРЕННЫЙ') return 1;
      return a['time'].compareTo(b['time']);
    });
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
          child: _buildContent(),
        ),
      ],
    ),
  );
}

Widget _buildContent() {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  
  if (_errorMessage != null) {
    return Center(child: Text(_errorMessage!));
  }
  
  if (_filteredCalls.isEmpty) {
    return const Center(child: Text('Нет вызовов на выбранную дату'));
  }
  
  return ResponsiveCardList(
    type: CardListType.calls,
    items: _filteredCalls,
    onItemTap: (context, item) => _openCallDetails(item),
    onRefresh: _refreshCalls,
  );
}
}