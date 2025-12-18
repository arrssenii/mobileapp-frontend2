// lib/data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({required String token, required int userId})
    : super(token: token, userId: userId);

  // Дополнительные методы для работы с моделью (если нужно)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Извлекаем значение id как Object
    final idValue = json['id']; // <-- Используем 'id', а не 'userId'

    // Преобразуем его в int, независимо от того, было ли оно строкой или числом
    int? parsedId;
    if (idValue != null) {
      if (idValue is int) {
        parsedId = idValue;
      } else if (idValue is String) {
        parsedId = int.tryParse(idValue);
        if (parsedId == null) {
          // Лучше бросить исключение, если ID обязателен и не может быть распарсен
          throw FormatException(
            'Невозможно преобразовать id в число: $idValue',
          );
        }
      } else {
        // Лучше бросить исключение, если ID обязателен и не является строкой или числом
        throw FormatException(
          'Неверный тип id: ${idValue.runtimeType}, ожидалось число или строка',
        );
      }
    } else {
      // Лучше бросить исключение, если ID обязателен и отсутствует
      throw FormatException('Поле id отсутствует в ответе сервера');
    }

    return UserModel(
      token: json['token'] as String, // <-- Убедимся, что token - String
      userId: parsedId, // <-- Передаём результат парсинга (int)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userId': userId, // <-- При отправке обратно можно использовать userId
    };
  }
}
