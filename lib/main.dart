import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Domain Layer
import 'domain/usecases/login_usecase.dart';
import 'domain/repositories/auth_repository.dart';

// Data Layer
import 'data/datasources/auth_remote_data_source.dart';
import 'data/models/user_model.dart';
import 'data/repositories/auth_repository_impl.dart';

// Presentation Layer
import 'presentation/pages/login_screen.dart';
import 'presentation/pages/main_screen.dart';
import 'presentation/bloc/login_bloc.dart';

// Services
import 'services/auth_service.dart'; // Добавляем импорт AuthService
import 'services/api_client.dart';
import 'services/websocket_service.dart';

// Theme
import 'core/theme/theme_config.dart';

// Providers
import 'providers/websocket_provider.dart';
import 'providers/calls_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final authService = AuthService(prefs);
  final apiClient = ApiClient(authService);
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

  final webSocketService = WebSocketService();

  runApp(
    MyApp(
      apiClient: apiClient,
      authRepository: authRepository,
      authService: authService,
      webSocketService: webSocketService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final AuthService authService;
  final WebSocketService webSocketService; // всё ещё создаём в main()

  const MyApp({
    super.key,
    required this.apiClient,
    required this.authRepository,
    required this.authService,
    required this.webSocketService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        Provider.value(value: authService),
        Provider<WebSocketService>(
          create: (_) => webSocketService,
          dispose: (_, service) => service.dispose(),
        ),
        // 👇 Добавляем WebSocketProvider и CallsProvider
        ChangeNotifierProvider(
          create: (_) => WebSocketProvider(webSocketService),
        ),
        ChangeNotifierProvider(create: (_) => CallsProvider()),
        BlocProvider(
          create: (context) =>
              LoginBloc(loginUseCase: LoginUseCase(authRepository)),
        ),
      ],
      child: MaterialApp(
        title: 'Медицинская информационная система',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru', 'RU')],
        theme: AppTheme.lightTheme,
        home: FutureBuilder<String?>(
          future: authService.getToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              // Проверяем только наличие токена, данные доктора не требуются
              return const MainScreen();
            }

            // Для тестирования WebSocket можно временно использовать тестовый экран
            // return const WebSocketTestScreen(userId: '1');
            return LoginScreen();
          },
        ),
      ),
    );
  }
}

// main.dart (измененная реализация AuthRemoteDataSourceImpl)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login(String phone, String password) async {
    try {
      final response = await apiClient.loginDoctor({
        'phone': phone,
        'password': password,
      });

      // Проверяем структуру ответа
      final responseData = response as Map<String, dynamic>;

      // Обрабатываем разные форматы ответа
      Map<String, dynamic> authData;
      if (responseData.containsKey('data')) {
        // Формат: {data: {id: 5, token: ...}, message: success, ...}
        authData = responseData['data'] as Map<String, dynamic>;
      } else {
        // Формат: {id: 5, token: ...}
        authData = responseData;
      }

      if (authData.containsKey('token') && authData.containsKey('id')) {
        // Преобразуем ID в int
        final userId = authData['id'] is int
            ? authData['id']
            : int.tryParse(authData['id'].toString());

        if (userId == null) {
          throw Exception('Неверный формат ID пользователя');
        }

        return UserModel(token: authData['token'] as String, userId: userId);
      } else {
        throw Exception(
          'Неверный формат ответа сервера: отсутствует токен или id',
        );
      }
    } on DioException catch (e) {
      throw Exception('Ошибка сети: ${e.message}');
    } on ApiError catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Неизвестная ошибка: ${e.toString()}');
    }
  }
}
