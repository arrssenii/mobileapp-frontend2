import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../data/models/doctor_model.dart';
import '../../core/theme/theme_config.dart';

import 'main_screen.dart';

import '../bloc/login_bloc.dart';
import '../../services/api_client.dart';
import '../widgets/design_system/input_fields.dart';

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
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Инициализация телефона происходит в ModernPhoneField
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorData(BuildContext context, int userId) async {
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      // TODO: Загружаем данные доктора когда будет готов API
      // final doctorData = await apiClient.getDoctorById(userId.toString());
      //
      // if (doctorData['id'] == null) {
      //   throw Exception('Сервер не вернул ID доктора');
      // }
      //
      // final responseId = doctorData['id'] is int
      //     ? doctorData['id']
      //     : int.tryParse(doctorData['id'].toString());
      //
      // if (responseId == null || responseId != userId) {
      //   throw Exception(
      //       'ID доктора в ответе ($responseId) не соответствует запрошенному ($userId)');
      // }
      //
      // final doctor = Doctor.fromJson(doctorData);
      // apiClient.setCurrentDoctor(doctor);
      debugPrint('🔄 ID доктора загружен: $userId');
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных доктора: $e')),
      );
      debugPrint('❌ Ошибка загрузки данных доктора: $e');
    }
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text;
      final password = _passwordController.text;

      context.read<LoginBloc>().add(LoginRequested(phone, password));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: FractionallySizedBox(
            widthFactor: 0.75,
            child: BlocConsumer<LoginBloc, LoginState>(
              listener: (context, state) async {
                if (state is LoginSuccess) {
                  await _loadDoctorData(context, state.userId);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                }
                if (state is LoginError) {
                  // --- ОТОБРАЖЕНИЕ СООБЩЕНИЯ ОБ ОШИБКЕ ---
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message,
                      ), // <-- Текст ошибки из LoginError
                      backgroundColor: Colors.red, // Цвет для ошибки
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Логотип
                      SizedBox(
                        // Оборачиваем SvgPicture.asset в SizedBox для точного контроля размера
                        width: 200, // Ширина логотипа
                        height: 200, // Высота логотипа
                        child: SvgPicture.asset(
                          'lib/core/assets/logo.svg',
                          fit: BoxFit
                              .contain, // Растягиваем изображение по контейнеру
                          colorFilter: ColorFilter.mode(
                            AppTheme.primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Авторизация',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppInputTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Поле телефона
                      ModernPhoneField(
                        controller: _phoneController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 24),

                      // Поле пароля
                      ModernFormField(
                        label: 'Пароль',
                        controller: _passwordController,
                        isRequired: true,
                        obscureText: true,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppInputTheme.textSecondary,
                        ),
                        hintText: 'Введите пароль',
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(context),
                      ),
                      const SizedBox(height: 32),

                      // Кнопка входа
                      ElevatedButton(
                        onPressed: state is LoginLoading
                            ? null
                            : () => _handleLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppInputTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: state is LoginLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Вход',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: 30),
                      const AppVersionWidget(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
