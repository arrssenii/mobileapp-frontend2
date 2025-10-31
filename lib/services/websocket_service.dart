// websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // общий интерфейс
import 'package:web_socket_channel/io.dart' show IOWebSocketChannel;
import 'package:web_socket_channel/html.dart' show HtmlWebSocketChannel;

/// Сервис для работы с WebSocket уведомлениями
class WebSocketService {
  static const String _baseUrl = 'ws://192.168.29.112:65323';
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
      if (kIsWeb) {
        // Для Flutter Web
        _channel = HtmlWebSocketChannel.connect(uri);
        debugPrint('🌐 WebSocket (Web): подключён для $userId');
      } else {
        // Для Android/iOS/Desktop
        _channel = IOWebSocketChannel.connect(uri);
        debugPrint('📱 WebSocket (Native): подключён для $userId');
      }
  
      _channelSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );
  
    } catch (e, stack) {
      debugPrint('❌ Ошибка WebSocket: $e\n$stack');
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

    debugPrint('🔌 WebSocket отключен');
  }

  /// Отправить сообщение через WebSocket
  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
      debugPrint('📤 Отправлено сообщение: $message');
    } else {
      debugPrint('⚠️ WebSocket не подключен, невозможно отправить сообщение');
    }
  }

  /// Обработка входящих сообщений
  void _handleMessage(dynamic message) {
    if (message == null) return;

    try {
      final jsonData = jsonDecode(message) as Map<String, dynamic>;
      debugPrint('📥 Получено JSON уведомление: $jsonData');

      _processNotification(jsonData);

      // Передаём в UI только валидные JSON-объекты
      _messageController.add(jsonData);
    } catch (e) {
      debugPrint('📥 Получено текстовое уведомление (не JSON): $message');
      // Опционально: можно отправлять строки в отдельный поток, но обычно не нужно
    }
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    debugPrint('❌ WebSocket ошибка: $error');
    if (stackTrace != null) debugPrint(stackTrace.toString());
    disconnect();
  }

  void _handleDisconnect() {
    debugPrint('🔌 WebSocket соединение закрыто');
    _channel = null;
    _currentUserId = null;
  }

  void _processNotification(Map<String, dynamic> notification) {
    final type = notification['type']?.toString();
    final data = notification['data'];

    switch (type) {
      case 'new_call':
        debugPrint('🚨 Новый вызов СМП: $data');
        break;
      case 'call_status_update':
        debugPrint('🔄 Обновление статуса вызова: $data');
        break;
      case 'new_reception':
        debugPrint('📋 Новый прием: $data');
        break;
      case 'emergency_alert':
        debugPrint('🚨 Срочное уведомление: $data');
        break;
      default:
        debugPrint('📢 Общее уведомление: $notification');
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