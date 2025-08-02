import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../data/models/doctor_model.dart';

import 'main_screen.dart';

import '../bloc/login_bloc.dart';
import '../../services/api_client.dart'; // Добавляем импорт ApiClient

class AppVersionWidget extends StatelessWidget {
  const AppVersionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiClient apiClient = Provider.of<ApiClient>(context, listen: false);
    final Future<String> versionFuture = apiClient.getAppVersion();

    return FutureBuilder<String>(
      future: versionFuture,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            snapshot.hasData ? 'Версия: ${snapshot.data}' : '',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}


class LoginScreen extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) async {
            if (state is LoginSuccess) {
              await _loadDoctorData(context, state.userId);
              
              // Переходим напрямую на MainScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            }
            if (state is LoginError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Авторизация',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Телефон',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    
                    ElevatedButton(
                      onPressed: state is LoginLoading
                          ? null
                          : () {
                              final phone = _usernameController.text;
                              // Валидация формата телефона
                              if (!_isValidPhone(phone)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Введите корректный номер телефона (+7XXXXXXXXXX)')),
                                );
                                return;
                              }
                              
                              context.read<LoginBloc>().add(LoginRequested(
                                phone,
                                _passwordController.text,
                              ));
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state is LoginLoading
                          ? const CircularProgressIndicator()
                          : const Text('Вход', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 30), 
                    const AppVersionWidget(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
bool _isValidPhone(String phone) {
  // Простая проверка: начинается с +7 и 10 цифр
  final regex = RegExp(r'^\+7\d{10}$');
  return regex.hasMatch(phone);
}

  // Загрузка данных доктора после успешной аутентификации
  Future<void> _loadDoctorData(BuildContext context, int userId) async {
  try {
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    
    // Преобразуем int в String для запроса
    final doctorData = await apiClient.getDoctorById(userId.toString());
    
    // Проверяем наличие ID
    if (doctorData['id'] == null) {
      throw Exception('Сервер не вернул ID доктора');
    }
    
    // Преобразуем ID доктора в int для проверки
    final responseId = doctorData['id'] is int 
        ? doctorData['id'] 
        : int.tryParse(doctorData['id'].toString());
    
    if (responseId == null || responseId != userId) {
      throw Exception('ID доктора в ответе ($responseId) не соответствует запрошенному ($userId)');
    }
    
    final doctor = Doctor.fromJson(doctorData);
    apiClient.setCurrentDoctor(doctor);
    await Future.delayed(const Duration(milliseconds: 100));
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка загрузки данных доктора: ${e.toString()}')),
    );
    
    // Дополнительное логирование
    debugPrint('❌ Ошибка загрузки данных доктора: ${e.toString()}');
  }
}
}