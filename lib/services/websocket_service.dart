import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Сервис для работы с WebSocket уведомлениями
class WebSocketService {
  static const String _baseUrl = 'ws://192.168.29.158:65323';
  static const String _endpoint = '/ws/notification/register';

  WebSocketChannel? _channel;
  String? _currentUserId;
  StreamSubscription? _channelSubscription;

  // Broadcast-контроллер для UI (поддерживает много слушателей)
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Поток для UI — можно слушать сколько угодно раз
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// Подключиться к WebSocket с указанным ID пользователя
  Future<void> connect(String userId) async {
    disconnect(); // Отключаемся, если уже подключены

    _currentUserId = userId;
    final uri = Uri.parse('$_baseUrl$_endpoint/$userId');

    try {
      // ✅ Используем общий метод — он сам выберет нужную реализацию
      _channel = WebSocketChannel.connect(uri);

      if (kDebugMode) {
        print('🌐 WebSocket: подключён для $userId');
      }

      _channelSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );
    } catch (e, stack) {
      print('❌ Ошибка WebSocket: $e\n$stack');
      _channel = null;
      _currentUserId = null;
      rethrow;
    }
  }

  /// Отключиться от WebSocket
  void disconnect() {
    _channelSubscription?.cancel();
    _channelSubscription = null;

    _channel?.sink.close();
    _channel = null;
    _currentUserId = null;

    if (kDebugMode) {
      print('🔌 WebSocket отключен');
    }
  }

  /// Отправить сообщение через WebSocket
  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
      if (kDebugMode) print('📤 Отправлено: $message');
    } else {
      if (kDebugMode) print('⚠️ WebSocket не подключен');
    }
  }

  /// Обработка входящих сообщений
  void _handleMessage(dynamic message) {
    if (message == null) return;

    try {
      final jsonData = jsonDecode(message) as Map<String, dynamic>;
      // debugPrint('📥 Получено JSON уведомление: $jsonData'); // ❌ УБРАТЬ
      print(
        '📥 Получено уведомление типа: ${jsonData['type']}',
      ); // ✅ Вывести только тип

      _processNotification(jsonData);

      _messageController.add(jsonData);
    } catch (e) {
      debugPrint('📥 Получено текстовое уведомление (не JSON): $message');
    }
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    print('❌ WebSocket ошибка: $error');
    if (stackTrace != null) print(stackTrace.toString());
    disconnect();
  }

  void _handleDisconnect() {
    print('🔌 WebSocket соединение закрыто');
    _channel = null;
    _currentUserId = null;
  }

  void _processNotification(Map<String, dynamic> notification) {
    final type = notification['type']?.toString();
    final data = notification['data'];

    switch (type) {
      case 'new_call':
        print('🚨 Новый вызов: $data');
        break;
      case 'call_status_update':
        print('🔄 Обновление статуса вызова: $data');
        break;
      case 'new_reception':
        print('📋 Новый прием: $data');
        break;
      case 'emergency_alert':
        print('🚨 Срочное уведомление: $data');
        break;
      default:
        print('📢 Общее уведомление: $notification');
    }
  }

  bool get isConnected => _channel != null;
  String? get currentUserId => _currentUserId;

  /// ВАЖНО: вызывать при уничтожении сервиса
  void dispose() {
    disconnect();
    _messageController.close();
  }
}
