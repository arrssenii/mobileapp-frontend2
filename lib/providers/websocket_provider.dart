import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';

class WebSocketProvider extends ChangeNotifier {
  final WebSocketService _webSocketService;

  // Храним вызовы, полученные через WebSocket
  List<Map<String, dynamic>> _calls = [];

  List<Map<String, dynamic>> get calls => _calls;

  WebSocketProvider(this._webSocketService);

  Future<void> connect(String userId) async {
    await _webSocketService.connect(userId);

    _webSocketService.messageStream.listen((message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type']?.toString();
    if (type == 'new_call') {
      final newCall = _transformWebSocketCall(
        message['data'] as Map<String, dynamic>,
      );
      _calls.insert(0, newCall);
      notifyListeners(); // Уведомляем всех слушателей
    } else if (type == 'call_status_update') {
      final callId = message['data']['call_id'];
      final newStatus = message['data']['status'];
      _updateCallStatus(callId, newStatus);
    }
  }

  Map<String, dynamic> _transformWebSocketCall(Map<String, dynamic> callData) {
    final dateStartStr = callData['dateStart'] as String?;
    final createdAt = dateStartStr != null
        ? DateTime.parse(dateStartStr).toLocal()
        : DateTime.now();
    final timeStr =
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

    // Из data берем client и doctor
    final client = callData['client'] as Map<String, dynamic>?;

    return {
      'id': callData['number'], // используем number как ID
      'date': createdAt,
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
          // добавь другие нужные поля
        },
      ],
      'isCompleted': false,
      // Оригинальные данные, если понадобятся
      'originalData': callData,
    };
  }

  void updateCallStatus(String callId, String status) {
    _updateCallStatus(callId, status);
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
