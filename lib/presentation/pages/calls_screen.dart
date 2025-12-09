import 'dart:convert';
import 'package:kvant_medpuls/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/websocket_provider.dart';
import '../../providers/calls_provider.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart'; // Добавляем импорт AuthService
import '../../services/websocket_service.dart';
import './call_detail_screen.dart';
import '../widgets/responsive_card_list.dart';
import '../widgets/date_carousel.dart';
import '../../core/theme/theme_config.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _filteredCalls = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupWebSocketListener();
    // ❌ УБРАТЬ _loadInitialCalls() — Consumer сам обновит UI
  }

  void _setupWebSocketListener() {
    // ❌ УБРАТЬ — Consumer сам слушает Provider
  }

  void _onWebSocketCallsUpdated() {
    // ❌ УБРАТЬ — Consumer сам обновит UI
  }

  // ❌ УБРАТЬ _loadInitialCalls()

  void _filterCallsByDate([List<Map<String, dynamic>>? allCalls]) {
    final calls =
        allCalls ??
        Provider.of<WebSocketProvider>(context, listen: false).calls;

    _filteredCalls = calls.where((call) {
      // ✅ Преобразуем строку в DateTime
      final callDateString = call['date'] as String;
      final callDate = DateTime.parse(callDateString);

      return callDate.year == _selectedDate.year &&
          callDate.month == _selectedDate.month &&
          callDate.day == _selectedDate.day;
    }).toList();

    _filteredCalls.sort((a, b) {
      // Завершённые вниз

      final aCompleted = a['executionStatus'] == 'Завершён';
      final bCompleted = b['executionStatus'] == 'Завершён';
      if (aCompleted && !bCompleted) return 1;
      if (!aCompleted && bCompleted) return -1;

      // Сначала экстренные
      final aEmergency = a['mainStatus'] == 'ЭКСТРЕННЫЙ';
      final bEmergency = b['mainStatus'] == 'ЭКСТРЕННЫЙ';
      if (aEmergency && !bEmergency) return -1;
      if (!aEmergency && bEmergency) return 1;

      // Потом сортировка по времени
      final aTimeString = a['date'] as String;
      final aTime = DateTime.parse(aTimeString);
      final bTimeString = b['date'] as String;
      final bTime = DateTime.parse(bTimeString);
      return aTime.compareTo(bTime);
    });

    // ❌ УБРАТЬ setState — Consumer сам перерисует UI
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      // ❌ НЕЛЬЗЯ вызывать _filterCallsByDate здесь, потому что Provider.of(context) будет бросать исключение
      // потому что context ещё не подписан на Provider через Consumer
    });
  }

  // ❌ УБРАТЬ _openCallDetails — определим ниже

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketProvider>(
      builder: (context, webSocketProvider, child) {
        // ✅ Передаём вызовы из Consumer
        _filterCallsByDate(webSocketProvider.calls);

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
                onPressed: () {},
                tooltip: 'Обновить список',
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          body: Column(
            children: [
              DateCarousel(
                initialDate: _selectedDate,
                // ❌ Тут тоже проблема — _handleDateSelected использует setState, но вызывается из UI
                // Лучше сделать так:
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                  // И перерисовка произойдёт автоматически через Consumer
                },
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
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
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
      onRefresh: () async {},
    );
  }

  void _openCallDetails(Map<String, dynamic> callData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CallDetailScreen(call: callData)),
    );
  }
}
