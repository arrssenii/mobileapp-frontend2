import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

/// Сервис для работы с WebSocket уведомлениями
class WebSocketService {
  static const String _baseUrl = 'ws://192.168.29.112:65323';
  static const String _endpoint = '/ws/notification/register';
  
  WebSocketChannel? _channel;
  String? _currentUserId;
  
  /// Подключиться к WebSocket с указанным ID пользователя
  Future<void> connect(String userId) async {
    try {
      // WebSocket не поддерживается в веб-версии
      if (kIsWeb) {
        debugPrint('⚠️ WebSocket не поддерживается в веб-версии');
        return;
      }
      
      _currentUserId = userId;
      final uri = Uri.parse('$_baseUrl$_endpoint/$userId');
      _channel = IOWebSocketChannel.connect(uri);
      
      debugPrint('✅ WebSocket подключен для пользователя: $userId');
      
      // Слушаем входящие сообщения
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );
    } catch (e) {
      debugPrint('❌ Ошибка подключения WebSocket: $e');
      rethrow;
    }
  }
  
  /// Отключиться от WebSocket
  void disconnect() {
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
  
  /// Получить поток сообщений
  Stream<dynamic> get messageStream {
    if (_channel != null) {
      return _channel!.stream;
    } else {
      return const Stream.empty();
    }
  }
  
  /// Обработка входящих сообщений
  void _handleMessage(dynamic message) {
    try {
      // Пытаемся распарсить JSON
      final jsonData = jsonDecode(message);
      debugPrint('📥 Получено JSON уведомление: $jsonData');
      
      // Здесь можно добавить логику обработки конкретных типов уведомлений
      _processNotification(jsonData);
    } catch (e) {
      // Если не JSON, обрабатываем как обычный текст
      debugPrint('📥 Получено текстовое уведомление: $message');
    }
  }
  
  /// Обработка ошибок WebSocket
  void _handleError(Object error) {
    debugPrint('❌ WebSocket ошибка: $error');
  }
  
  /// Обработка отключения WebSocket
  void _handleDisconnect() {
    debugPrint('🔌 WebSocket соединение закрыто');
    _channel = null;
  }
  
  /// Обработка конкретных типов уведомлений
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
  
  /// Проверить статус подключения
  bool get isConnected => _channel != null;
  
  /// Получить текущий ID пользователя
  String? get currentUserId => _currentUserId;
}