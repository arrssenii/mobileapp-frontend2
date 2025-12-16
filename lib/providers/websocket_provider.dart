import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../services/cache_service.dart';

class WebSocketProvider extends ChangeNotifier {
  final WebSocketService _webSocketService;

  // Храним вызовы, полученные через WebSocket
  List<Map<String, dynamic>> _calls = [];

  List<Map<String, dynamic>> get calls => _calls;

  WebSocketProvider(this._webSocketService) {
    // ✅ Загружаем вызовы из кэша при создании провайдера
    _loadCallsFromCache();
  }

  Future<void> _loadCallsFromCache() async {
    try {
      _calls = await CacheService.loadCalls();
      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки вызовов из кэша: $e');
    }
  }

  Future<void> connect(String userId) async {
    await _webSocketService.connect(userId);

    _webSocketService.messageStream.listen((message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type']?.toString();
    if (type == 'new_call') {
      // ✅ Передаём ВСЁ сообщение, а не только message['data']
      final newCall = _transformWebSocketCall(message);
      _calls.insert(0, newCall);
      notifyListeners(); // Уведомляем всех слушателей

      // ✅ Сохраняем вызовы в кэш
      CacheService.saveCalls(_calls);
    } else if (type == 'call_status_update') {
      final callId = message['data']['call_id'];
      final newStatus = message['data']['status'];
      _updateCallStatus(callId, newStatus);
    }
  }

  // ✅ Счётчик для генерации уникальных receptionId
  int _receptionIdCounter =
      1000; // Начинаем с 1000, чтобы не пересекаться с реальными ID

  // ✅ Принимаем ВСЁ сообщение, а не только data
  Map<String, dynamic> _transformWebSocketCall(
    Map<String, dynamic> fullMessage,
  ) {
    // ✅ Берём data из сообщения
    final callData = fullMessage['data'] as Map<String, dynamic>;

    // ✅ Берём шаблоны из корня сообщения (не из data!)
    final List<dynamic>? availableTemplates =
        fullMessage['template'] as List<dynamic>?;
    // Также берём коды шаблонов (если они есть отдельно)
    final List<dynamic>? templateCodes =
        fullMessage['templates'] as List<dynamic>? ??
        callData['templates'] as List<dynamic>?;

    final dateStartStr = callData['dateStart'] as String?;
    final createdAt = dateStartStr != null
        ? DateTime.parse(dateStartStr).toLocal()
        : DateTime.now();
    final timeStr =
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

    // Из data берем client и doctor
    final client = callData['client'] as Map<String, dynamic>?;

    List<dynamic> filteredTemplates = [];

    if (availableTemplates != null) {
      if (templateCodes != null) {
        // ✅ Фильтруем шаблоны по кодам
        filteredTemplates = availableTemplates.where((template) {
          final code = template['templateCode'] as String?;
          return templateCodes.contains(code);
        }).toList();
      } else {
        // Если коды не указаны, используем все доступные шаблоны
        filteredTemplates = List.from(availableTemplates);
      }
    }

    print('🔍 Фильтрация шаблонов:');
    print('  - templateCodes: $templateCodes');
    print('  - availableTemplates count: ${availableTemplates?.length}');
    print('  - filteredTemplates count: ${filteredTemplates.length}');

    return {
      'id': callData['number'], // используем number как ID
      'date': createdAt.toIso8601String(), // ✅ Преобразуем DateTime в строку
      'address': callData['address'] ?? 'Адрес не указан',
      'phone':
          client?['phone'] ?? 'Телефон не указан', // если phone есть в client
      'emergency':
          callData['type_id'] ==
          0, // если type_id == 0, то это экстренный вызов?
      'mainStatus': callData['type_id'] == 0 ? 'ЭКСТРЕННЫЙ' : 'НЕОТЛОЖНЫЙ',
      'executionStatus': 'Выполняется',
      'time': timeStr,
      'patients': [
        // ✅ Добавляем пациента из WebSocket с нужными полями
        {
          'id': client?['code'], // код пациента
          'name': client?['name'] ?? 'Пациент неизвестен',
          'hasConclusion': false, // пока нет диагноза
          // ✅ Добавляем поля, которые ожидаются в PatientCardWidget
          'firstName':
              client?['name']?.split(' ')[1] ??
              '', // "Яшкина Светлана Витальевна" -> "Светлана"
          'lastName': client?['name']?.split(' ')[0] ?? '', // -> "Яшкина"
          'middleName': client?['name']?.split(' ')[2] ?? '', // -> "Витальевна"
          'birthDate': client?['birthDate'], // если birthDate есть
          // ✅ Генерируем уникальный receptionId
          'receptionId': _receptionIdCounter++, // Увеличиваем счётчик
          // ✅ Передаём ОТФИЛЬТРОВАННЫЕ шаблоны
          'templates': filteredTemplates.cast<Map<String, dynamic>>(),
        },
      ],
      'isCompleted': false,
      // ✅ Сохраняем ОТФИЛЬТРОВАННЫЕ шаблоны из WebSocket (опционально, можно и в patients)
      'templates': filteredTemplates.cast<Map<String, dynamic>>(),
      // Оригинальные данные, если понадобятся
      'originalData': callData,
    };
  }

  void updateCallStatus(String callId, String status) {
    _updateCallStatus(callId, status);

    // ✅ Сохраняем вызовы в кэш
    CacheService.saveCalls(_calls);
  }

  void _updateCallStatus(String callId, String status) {
    final index = _calls.indexWhere((call) => call['id'] == callId);
    if (index != -1) {
      _calls[index]['executionStatus'] = status;
      _calls[index]['isCompleted'] = status == 'Завершён';
      notifyListeners();
    }
  }
}
