import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Условный импорт для sqflite
import 'package:sqflite/sqflite.dart' as sqflite_default;
// Импорт sqflite_common_ffi
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as sqflite_ffi_web;
import 'package:path/path.dart'; // Добавьте этот импорт

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

// Theme
import 'core/theme/theme_config.dart';

Future<void> initDb() async {
  // WidgetsFlutterBinding.ensureInitialized(); <- вызывается в main()

  if (kIsWeb) {
    // Для Web используем sqflite_common_ffi_web
    sqflite_default.databaseFactory = sqflite_ffi_web.databaseFactoryFfiWeb;
    debugPrint("🔧 sqflite инициализирован для Web (FFI Web)");
  } else {
    // Для мобильных платформ (Android, iOS) используем стандартный sqflite
    debugPrint("🔧 sqflite инициализирован для мобильной платформы");
    // sqflite_default.databaseFactory остается по умолчанию
  }

  // На Web, вызов databaseFactoryFfiWeb может сам инициализировать необходимые внутренние компоненты.
  // Явный вызов initDatabaseFfi или открытие временной БД может не понадобиться,
  // но если возникнут трудности, можно попробовать.
  // await sqflite_ffi_web.initDatabaseFfiWeb();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDb();
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService(prefs);
  final apiClient = ApiClient(authService);
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

  runApp(
    MyApp(
      apiClient: apiClient,
      authRepository: authRepository,
      authService: authService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final AuthService authService;

  const MyApp({
    super.key,
    required this.apiClient,
    required this.authRepository,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // MultiProvider предоставляет apiClient и authService всему приложению
      providers: [
        Provider.value(value: apiClient),
        Provider.value(value: authService),
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
              return const MainScreen();
            }

            // ✅ ВАЖНОЕ ИЗМЕНЕНИЕ: Оборачиваем LoginScreen в BlocProvider
            // Теперь LoginScreen имеет доступ к LoginBloc
            return BlocProvider(
              create: (context) =>
                  LoginBloc(loginUseCase: LoginUseCase(authRepository)),
              child: LoginScreen(),
            );
          },
        ),
      ),
    );
  }
}
