import '../models/user_model.dart';
import 'package:dio/dio.dart';
import '../../services/api_client.dart';

abstract class AuthRemoteDataSource {
  // Изменим сигнатуру метода login, чтобы она соответствовала вашему API
  // Ваш API принимает Map<String, dynamic> с 'username' и 'password'
  Future<UserModel> login(String phone, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login(String phone, String password) async {
    // Вызываем метод из ApiClient для выполнения логина
    // Предположим, ваш ApiClient.loginDoctor возвращает Map<String, dynamic>
    final response = await apiClient.loginDoctor({
      'phone': phone, // Или 'phone' если ваш API ожидает телефон
      'password': password,
    });

    // Преобразуем ответ от ApiClient в UserModel
    // Проверим структуру ответа, которую возвращает apiClient.loginDoctor
    // Судя по вашему коду, успешный ответ может быть {data: {id: X, token: Y}} или {id: X, token: Y}
    Map<String, dynamic> authData;
    if (response.containsKey('data')) {
      authData = response['data'] as Map<String, dynamic>;
    } else {
      authData = response;
    }

    // Создаем и возвращаем экземпляр UserModel
    // Убедитесь, что ваш UserModel.fromJson принимает такие ключи ('id', 'token')
    return UserModel.fromJson(authData);
  }
}
