// lib/presentation/pages/calls_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import 'call_detail_screen.dart';
import 'login_screen.dart';
import '../widgets/responsive_card_list.dart';
import '../widgets/date_carousel.dart';
import '../../core/theme/theme_config.dart';
import '../../services/emergency_call_database_service.dart';
import '../../data/models/emergency_call_model.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  DateTime _selectedDate = DateTime.now();
  List<EmergencyCall> _calls = [];
  List<EmergencyCall> _filteredCalls = [];
  bool _isLoading = false; // Для индикатора загрузки данных с сервера
  bool _isLoadingCache =
      true; // Для индикатора загрузки кэша при первом запуске
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData(); // Объединяем загрузку кэша и сервера
  }

  // Объединённая функция для инициализации
  Future<void> _loadData() async {
    await _loadCachedCalls(); // Сначала загружаем кэш и показываем его
    await _loadCallsFromServer(); // Потом обновляем с сервера
  }

  Future<void> _loadCachedCalls() async {
    try {
      final cachedCalls = await EmergencyCallDatabaseService().getAllCalls();
      if (mounted) {
        // Проверяем, что виджет всё ещё смонтирован
        setState(() {
          _calls = cachedCalls;
          _filterCallsByDate();
          _isLoadingCache = false; // Кэш загружен, скрываем индикатор
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки кэшированных вызовов: $e');
      if (mounted) {
        setState(() {
          _isLoadingCache = false; // Даже при ошибке кэша, убираем индикатор
          // _errorMessage = 'Ошибка загрузки кэша: $e'; // Не показываем ошибку кэша, если есть данные с сервера
        });
      }
    }
  }

  Future<void> _loadCallsFromServer() async {
    setState(() {
      _isLoading = true; // Показываем индикатор обновления
      // _errorMessage = null; // Не очищаем ошибку при обновлении, чтобы она оставалась видимой
    });

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final doctorId = await authService.getDoctorId();

      if (doctorId == null) {
        throw Exception('ID доктора не найден');
      }

      final callsResponse = await apiClient.getEmergencyCallsByDoctorAndDate(
        doctorId,
      );

      final callsData = callsResponse['data'] as List<dynamic>?;

      if (callsData == null) {
        throw Exception('Получен некорректный ответ от сервера (вызовы)');
      }

      List<EmergencyCall> serverCalls = callsData.map((callData) {
        return EmergencyCall(
          id: callData['id'] as int,
          number: callData['number'] as String,
          address: callData['address'] as String,
          doctorCode: callData['doctor_code'] as String,
          status: callData['status'] as String,
          createdAt: DateTime.parse(callData['created_at']),
          updatedAt: DateTime.parse(callData['updated_at']),
          templates: (callData['templates'] as List).cast<String>(),
          rawData: callData['raw_data'] as Map<String, dynamic>,
        );
      }).toList();

      // Обновляем кэш
      await EmergencyCallDatabaseService().clearAllCalls();
      await EmergencyCallDatabaseService().insertCalls(serverCalls);

      // Обновляем UI с новыми данными
      if (mounted) {
        // Проверяем, что виджет всё ещё смонтирован
        setState(() {
          _calls = serverCalls; // Заменяем локальный список
          _filterCallsByDate(); // Применяем фильтр по дате
          _errorMessage = null; // Очищаем ошибку, если успешно загрузили
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Ошибка загрузки вызовов: $e';
        });
      }
      debugPrint('Ошибка загрузки вызовов с сервера: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Скрываем индикатор обновления
        });
      }
    }
  }

  Future<void> _refreshCalls() async {
    await _loadCallsFromServer();
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filterCallsByDate(); // Фильтруем по новой дате
    });
  }

  void _filterCallsByDate() {
    _filteredCalls = _calls.where((call) {
      final callDate = call.createdAt;
      return callDate.year == _selectedDate.year &&
          callDate.month == _selectedDate.month &&
          callDate.day == _selectedDate.day;
    }).toList();

    _filteredCalls.sort((a, b) {
      final aCompleted = a.status == 'completed';
      final bCompleted = b.status == 'completed';
      if (aCompleted && !bCompleted) return 1;
      if (!aCompleted && bCompleted) return -1;
      return b.createdAt.compareTo(a.createdAt);
    });

    if (mounted) setState(() {}); // Обновляем UI
  }

  void _openCallDetails(EmergencyCall call) {
    final rawData = call.rawData as Map<String, dynamic>?;
    final clientInfo = rawData?['client'] as Map<String, dynamic>?;

    List<Map<String, dynamic>> patientsForThisCall = [];
    if (clientInfo != null) {
      final fullName = clientInfo['name'] as String;
      final nameParts = fullName.split(' ');
      final lastName = nameParts.isNotEmpty ? nameParts[0] : '';
      final firstName = nameParts.length > 1 ? nameParts[1] : '';
      final middleName = nameParts.length > 2
          ? nameParts.sublist(2).join(' ')
          : '';

      patientsForThisCall = [
        {
          'firstName': firstName,
          'lastName': lastName,
          'middleName': middleName,
          'birth_date': clientInfo['birthDate'],
          'is_male': true,
          'patientId': clientInfo['code'],
          'receptionId': call.id,
          'hasConclusion': false,
        },
      ];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallDetailScreen(
          callId: call.id,
          callTime:
              call.createdAt.hour.toString().padLeft(2, '0') +
              ':' +
              call.createdAt.minute.toString().padLeft(2, '0'),
          callAddress: call.address,
          callPhone: call.rawData['client']?['phone'] ?? 'Телефон не указан',
          callStatus: call.status,
          patients: patientsForThisCall,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadCallsFromServer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Вызовы',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.logout, color: AppTheme.textSecondary),
          tooltip: 'Выйти',
          onPressed: () {
            Provider.of<ApiClient>(context, listen: false).logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCalls,
            tooltip: 'Обновить список',
            color: AppTheme.textSecondary,
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Показываем индикатор загрузки кэша только при первом запуске и если нет данных
    if (_isLoadingCache && _filteredCalls.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Показываем сообщение об ошибке, если она есть и список пуст
    if (_errorMessage != null && _filteredCalls.isEmpty) {
      return Center(child: Text(_errorMessage!));
    }

    // Если кэш загружен, но нет вызовов на выбранную дату
    if (_filteredCalls.isEmpty) {
      return const Center(child: Text('Нет вызовов на выбранную дату'));
    }

    // Если есть данные, показываем их
    final items = _filteredCalls
        .map(
          (call) => {
            'id': call.id,
            'time':
                call.createdAt.hour.toString().padLeft(2, '0') +
                ':' +
                call.createdAt.minute.toString().padLeft(2, '0'),
            'address': call.address,
            'phone': call.rawData['client']?['phone'] ?? 'Телефон не указан',
            'executionStatus': call.status,
            'raw_data': call.rawData,
          },
        )
        .toList();

    // Оборачиваем ResponsiveCardList в Stack, чтобы показать индикатор обновления поверх
    return Stack(
      children: [
        ResponsiveCardList(
          type: CardListType.calls,
          items: items,
          onItemTap: (context, item) {
            final callObject = _calls.firstWhere(
              (call) => call.id == item['id'],
            );
            _openCallDetails(callObject);
          },
          onRefresh: _refreshCalls,
        ),
        if (_isLoading) // Показываем индикатор обновления поверх списка
          Container(
            color: Colors.black.withOpacity(0.1), // Легкий оверлей
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
