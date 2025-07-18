import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'main_screen.dart';

import '../bloc/login_bloc.dart';
import '../../services/api_client.dart'; // Добавляем импорт ApiClient

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
              await _loadDoctorData(context);
              
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
                        labelText: 'Логин',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
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
                              context.read<LoginBloc>().add(LoginRequested(
                                    _usernameController.text,
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  // Загрузка данных доктора после успешной аутентификации
  Future<void> _loadDoctorData(BuildContext context) async {
  try {
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    const doctorId = '1';
    
    final doctorData = await apiClient.getDoctorById(doctorId);
    
    // Проверяем наличие ID
    if (doctorData['id'] == null) {
      throw Exception('Сервер не вернул ID доктора');
    }
    
    apiClient.setCurrentDoctor(doctorData);
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