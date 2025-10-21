// lib/core/di/injection_container.dart

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../data/datasources/patient_remote_data_source.dart';
import '../../data/datasources/doctor_remote_data_source.dart';
import '../../data/datasources/emergency_remote_data_source.dart';
import '../../data/datasources/med_service_remote_data_source.dart';
import '../../data/repositories/patient_repository_impl.dart';
import '../../data/repositories/doctor_repository_impl.dart';
import '../../data/repositories/emergency_repository_impl.dart';
import '../../data/repositories/med_service_repository_impl.dart';
import '../../domain/repositories/patient_repository.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../../domain/repositories/med_service_repository.dart';
import '../../domain/usecases/create_patient.dart';
import '../../domain/usecases/get_patient.dart';
import '../../domain/usecases/update_patient.dart';
import '../../domain/usecases/search_patients.dart';
import '../../domain/usecases/create_doctor.dart';
import '../../domain/usecases/get_doctor.dart';
import '../../domain/usecases/create_emergency_reception.dart';
import '../../domain/usecases/get_doctor_emergencies.dart';
import '../../domain/usecases/update_emergency_status.dart';
import '../../domain/usecases/get_med_services.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // 1. Инициализация Dio и других базовых зависимостей
  await _initCore();
  
  // 2. Инициализация зависимостей пациента
  await _initPatientDependencies();
  
  // 3. Инициализация зависимостей врача
  await _initDoctorDependencies();
  
  // 4. Инициализация зависимостей экстренных случаев
  await _initEmergencyDependencies();
  
  // 5. Инициализация зависимостей медицинских услуг
  await _initMedServiceDependencies();
}

Future<void> _initCore() async {
  // Настройка Dio с интерсепторами
  getIt.registerSingleton<Dio>(Dio(BaseOptions(
    baseUrl: 'https://your-medical-api.com/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  )));
  
  // Добавляем интерсепторы
  final dio = getIt<Dio>();
  dio.interceptors.add(LogInterceptor(
    request: true,
    responseBody: true,
    requestBody: true,
    requestHeader: true,
  ));
}

Future<void> _initPatientDependencies() async {
  // DataSources
  getIt.registerLazySingleton<PatientRemoteDataSource>(
    () => PatientRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Repositories
  getIt.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(
      remoteDataSource: getIt<PatientRemoteDataSource>(),
    ),
  );

  // UseCases
  getIt.registerLazySingleton(() => CreatePatient(getIt<PatientRepository>()));
  getIt.registerLazySingleton(() => GetPatient(getIt<PatientRepository>()));
  getIt.registerLazySingleton(() => UpdatePatient(getIt<PatientRepository>()));
  getIt.registerLazySingleton(() => SearchPatients(getIt<PatientRepository>()));
}

Future<void> _initDoctorDependencies() async {
  // DataSources
  getIt.registerLazySingleton<DoctorRemoteDataSource>(
    () => DoctorRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Repositories
  getIt.registerLazySingleton<DoctorRepository>(
    () => DoctorRepositoryImpl(
      remoteDataSource: getIt<DoctorRemoteDataSource>(),
    ),
  );

  // UseCases
  getIt.registerLazySingleton(() => CreateDoctor(getIt<DoctorRepository>()));
  getIt.registerLazySingleton(() => GetDoctor(getIt<DoctorRepository>()));
}

Future<void> _initEmergencyDependencies() async {
  // DataSources
  getIt.registerLazySingleton<EmergencyRemoteDataSource>(
    () => EmergencyRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Repositories
  getIt.registerLazySingleton<EmergencyReceptionRepository>(
    () => EmergencyReceptionRepositoryImpl(
      remoteDataSource: getIt<EmergencyRemoteDataSource>(),
    ),
  );

  // UseCases
  getIt.registerLazySingleton(() => CreateEmergencyReception(getIt<EmergencyReceptionRepository>()));
  getIt.registerLazySingleton(() => GetDoctorEmergencies(getIt<EmergencyReceptionRepository>()));
  getIt.registerLazySingleton(() => UpdateEmergencyStatus(getIt<EmergencyReceptionRepository>()));
}

Future<void> _initMedServiceDependencies() async {
  // DataSources
  getIt.registerLazySingleton<MedServiceRemoteDataSource>(
    () => MedServiceRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Repositories
  getIt.registerLazySingleton<MedServiceRepository>(
    () => MedServiceRepositoryImpl(
      remoteDataSource: getIt<MedServiceRemoteDataSource>(),
    ),
  );

  // UseCases
  getIt.registerLazySingleton(() => GetMedServices(getIt<MedServiceRepository>()));
}

// Для тестов можно зарегистрировать mock-реализации
void registerTestDependencies() {
  // Пример для тестов:
  // getIt.registerSingleton<Dio>(MockDio());
  // getIt.registerSingleton<PatientRepository>(MockPatientRepository());
}
