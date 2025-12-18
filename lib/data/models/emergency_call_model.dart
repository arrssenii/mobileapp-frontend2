// lib/data/models/emergency_call_model.dart
import 'dart:convert'; // Добавьте импорт

class EmergencyCall {
  final int id;
  final String number;
  final String address;
  final String doctorCode;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> templates;
  final Map<String, dynamic> rawData; // Полностью сохраняем raw_data

  EmergencyCall({
    required this.id,
    required this.number,
    required this.address,
    required this.doctorCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.templates,
    required this.rawData, // Важно: сохраняем как Map
  });

  // Конвертируем Map (из JSON/SQLite) в объект Dart
  factory EmergencyCall.fromJson(Map<String, dynamic> json) {
    return EmergencyCall(
      id: json['id'] as int,
      number: json['number'] as String,
      address: json['address'] as String,
      doctorCode: json['doctor_code'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      templates: (json['templates'] as List<dynamic>).cast<String>(),
      rawData:
          json['raw_data']
              as Map<String, dynamic>, // Предполагаем, что уже распаршено
    );
  }

  // Конвертируем объект Dart в Map (для JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'address': address,
      'doctor_code': doctorCode,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'templates': templates,
      'raw_data': rawData,
    };
  }

  // Конвертируем объект Dart в Map для вставки в SQLite (rawData как строка)
  Map<String, dynamic> toDatabaseInsertMap() {
    return {
      'id': id,
      'number': number,
      'address': address,
      'doctor_code': doctorCode,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'templates': templates.join(','), // Сохраняем как строку
      'raw_data': jsonEncode(rawData), // Сохраняем как строку JSON
    };
  }

  // Конвертируем объект из SQLite (rawData как строка) в Dart объект
  factory EmergencyCall.fromDatabase(Map<String, dynamic> map) {
    // Парсим строки обратно в нужные типы
    final templates = (map['templates'] as String)
        .split(',')
        .where((s) => s.isNotEmpty)
        .toList();
    // Парсим строку JSON обратно в Map
    final rawMap =
        jsonDecode(map['raw_data'] as String) as Map<String, dynamic>;

    return EmergencyCall(
      id: map['id'] as int,
      number: map['number'] as String,
      address: map['address'] as String,
      doctorCode: map['doctor_code'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      templates: templates,
      rawData: rawMap, // Используем распаршенный Map
    );
  }
}
