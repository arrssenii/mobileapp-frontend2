import 'package:dio/dio.dart';
import 'auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../data/models/patient_model.dart';
import '../data/models/doctor_model.dart';

class ApiClient {
  late Dio _dio;
  String? _authToken;
  Doctor? _currentDoctor;
  final AuthService _authService;

  final String baseUrl = 'http://192.168.30.106:8080/api/v1';

  ApiClient(this._authService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    _setupInterceptors();
    _loadToken();
  }

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('API Request: ${options.method} ${options.uri}');
          debugPrint('Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('Body: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('API Response [${response.statusCode}]: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('API Error: ${e.message}');
          if (e.response != null) {
            final statusCode = e.response!.statusCode;
            final errorData = e.response!.data as Map<String, dynamic>?;
            throw ApiError(
              statusCode: statusCode,
              message: errorData?['message'] ?? 'Unknown error',
              rawError: errorData,
            );
          }
          return handler.next(e);
        },
      ),
    );
  }

  void setCurrentDoctor(Doctor doctor) {
    _currentDoctor = doctor;
    debugPrint('✅ Доктор установлен: ID=${doctor.id}');
  }

  // Добавляем метод getToken
  Future<String?> getToken() async {
    return await _authService.getToken();
  }

  Future<void> _loadToken() async {
    _authToken = await _authService.getToken();
    if (_authToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_authToken';
      
      // Загружаем ID доктора
      final doctorId = await _authService.getDoctorId();
      if (doctorId != null) {
        try {
          // Загружаем полные данные доктора
          final doctorData = await getDoctorById(doctorId);
          _currentDoctor = Doctor.fromJson(doctorData);
          debugPrint('🔄 Данные доктора загружены из хранилища: ${_currentDoctor!.fullTitle}');
        } catch (e) {
          debugPrint('⚠️ Ошибка загрузки данных доктора: $e');
        }
      }
    }
  }

  Future<Map<String, dynamic>> getReceptionDetails(
    String doctorId, 
    String receptionId,
    ) async {
    return _handleApiCall(
      () async {
        final response = await _dio.get(
          '/hospital/receptions/$doctorId/$receptionId',
        );
        
        if (response.statusCode != 200) {
          throw ApiError(
            statusCode: response.statusCode,
            message: 'Ошибка сервера: ${response.statusCode}',
            rawError: response.data,
          );
        }
        
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Ошибка загрузки деталей приёма',
    );
  }

  Future<Map<String, dynamic>> loginDoctor(Map<String, dynamic> credentials) async {
    try {
      final response = await _dio.post('/auth', data: credentials);
      
      if (response.statusCode == 200) {
        // Сохраняем токен
        if (response.data['token'] != null) {
          _authToken = response.data['token'];
          await _authService.saveToken(_authToken!);
          _dio.options.headers['Authorization'] = 'Bearer $_authToken';
        }
        
        // Сохраняем ID доктора
        if (response.data['id'] != null) {
          final doctorId = response.data['id'].toString();
          await _authService.saveDoctorId(doctorId);
          
          // Загружаем полные данные доктора
          final doctorData = await getDoctorById(doctorId);
          _currentDoctor = Doctor.fromJson(doctorData); // Используем модель Doctor
          debugPrint('🔑 Доктор авторизован: ${_currentDoctor!.fullTitle}');
        }
        
        return response.data;
      } else {
        throw ApiError(
          statusCode: response.statusCode,
          message: response.data['message'] ?? 'Ошибка авторизации',
          rawError: response.data,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'Сетевая ошибка при авторизации');
    }
  }

  Future<Map<String, dynamic>> getDoctorById(String docId) async {
    return _handleApiCall(
      () async {
        final response = await _dio.get('/doctors/$docId');

        if (response.statusCode != 200) {
          throw ApiError(
            statusCode: response.statusCode,
            message: 'Ошибка сервера: ${response.statusCode}',
            rawError: response.data,
          );
        }

        // Проверяем наличие данных
        if (response.data == null || 
            response.data is! Map<String, dynamic> || 
            response.data['data'] == null) {
          throw ApiError(
            message: 'Неверный формат ответа',
            rawError: response.data,
          );
        }

        return response.data['data'] as Map<String, dynamic>;
      },
      errorMessage: 'Ошибка получения данных доктора',
    );
  }

  Doctor? get currentDoctor => _currentDoctor;
  int? get currentDoctorId => _currentDoctor?.id;

  Future<void> logout() async {
    await _authService.clearAll();
    _authToken = null;
    _currentDoctor = null;
    _dio.options.headers.remove('Authorization');
  }
  
  // Добавляем метод для получения данных текущего пользователя (если есть такой эндпоинт)
  Future<Map<String, dynamic>> getCurrentUser() async {
    return _handleApiCall(
      () => _dio.get('/users/me').then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка получения данных пользователя',
    );
  }

  Future<Map<String, dynamic>> updateDoctor(String docId, Map<String, dynamic> data) async {
    return _handleApiCall(
      () => _dio.put('/doctors/$docId', data: data).then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка обновления данных доктора',
    );
  }

  // Пациенты
  Future<List<dynamic>> getAllPatients(String docId) async {
    return _handleApiCall(
      () async {
        final response = await _dio.get('/patients');
        // Достаем пациентов из data->hits
        return response.data['data']['hits'] as List<dynamic>;
      },
      errorMessage: 'Ошибка загрузки пациентов',
    );
  }

  Future<Map<String, dynamic>> getPatientById(String patId) async {
    return _handleApiCall(
      () => _dio.get('/patients/$patId').then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка получения данных пациента',
    );
  }

  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> patientData) async {
    return _handleApiCall(
      () => _dio.post(
        '/patients/', 
        data: patientData,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      ).then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка создания пациента',
    );
  }

  Future<Map<String, dynamic>> updatePatient(String patId, Map<String, dynamic> data) async {
    return _handleApiCall(
      () => _dio.put('/patients/$patId', data: data).then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка обновления данных пациента',
    );
  }

  Future<void> deletePatient(String patId) async {
    return _handleApiCall(
      () => _dio.delete('/patients/$patId'),
      errorMessage: 'Ошибка удаления пациента',
    );
  }

  // services/api_client.dart
  Future<List<dynamic>> getPatientReceptionsHistory(String patientId) async {
    return _handleApiCall(
      () async {
        final response = await _dio.get('/hospital/receptions/patients/$patientId');

        // Правильно извлекаем данные из вложенной структуры
        if (response.data is! Map<String, dynamic> || 
            response.data['data'] == null ||
            response.data['data']['hits'] == null) {
          throw ApiError(message: 'Некорректный формат ответа сервера');
        }

        return response.data['data']['hits'] as List<dynamic>;
      },
      errorMessage: 'Ошибка загрузки истории приёмов пациента',
    );
  }

  // Медкарты
  // services/api_client.dart
  Future<Patient> getMedCardByPatientId(String patId) async {
    return _handleApiCall(
      () async {
        final response = await _dio.get('/medcard/$patId');
        
        if (response.statusCode != 200) {
          throw ApiError(
            statusCode: response.statusCode,
            message: 'Ошибка сервера: ${response.statusCode}',
            rawError: response.data,
          );
        }
        
        return Patient.fromMedCardJson(response.data);
      },
      errorMessage: 'Ошибка загрузки медкарты',
    );
  }

  Future<Map<String, dynamic>> updateMedCard(String patId, Map<String, dynamic> data) async {
    return _handleApiCall(
      () async {
        final response = await _dio.put(
          '/medcard/$patId', 
          data: data,
          options: Options(
            contentType: Headers.jsonContentType,
          ),
        );

        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Ошибка обновления медкарты',
    );
  }

  // Приёмы в стационаре
  Future<Map<String, dynamic>> getReceptionsHospitalByDoctorAndDate(
    String docId, {
    required DateTime date,
    int page = 1,
  }) async {
    final formattedDate = _formatDate(date);
    return _handleApiCall(
      () async {
        final response = await _dio.get(
          '/hospital/receptions/$docId',
          queryParameters: {
            'filter': 'date.eq.$formattedDate',
            'page': page,
          },
        );
        
        // Возвращаем ВЕСЬ объект ответа
        return response.data as Map<String, dynamic>;
      },
      errorMessage: 'Ошибка загрузки приёмов в стационаре',
    );
  }

  Future<Map<String, dynamic>> updateReceptionHospital(
    String recepId,
    Map<String, dynamic> data,
  ) async {
    return _handleApiCall(
      () => _dio.put('/hospital/receptions/$recepId', data: data).then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка обновления приёма в стационаре',
    );
  }

  // Приёмы СМП
  Future<List<dynamic>> getReceptionsSMPByDoctorAndDate(
    String docId, {
    required DateTime date,
    int page = 1,
  }) async {
    final formattedDate = _formatDate(date);
    return _handleApiCall(
      () async {
        final response = await _dio.get(
          '/smp/doctors/$docId/receptions',
          queryParameters: {
            'date': formattedDate,
            'page': page,
          },
        );
        return response.data['data'] as List<dynamic>;
      },
      errorMessage: 'Ошибка загрузки приёмов СМП',
    );
  }

  Future<Map<String, dynamic>> getReceptionWithMedServices(String smpId) async {
    return _handleApiCall(
      () => _dio.get('/smp/$smpId').then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка загрузки приёма СМП с услугами',
    );
  }

  // Звонки СМП
  Future<List<dynamic>> getEmergencyCallsByDoctorAndDate(
    String docId, {
    required DateTime date,
    int page = 1,
  }) async {
    final formattedDate = _formatDate(date);
    return _handleApiCall(
      () async {
        final response = await _dio.get(
          '/emergency/$docId',
          queryParameters: {
            'date': formattedDate,
            'page': page,
          },
        );
        return response.data['hits'] as List<dynamic>;
      },
      errorMessage: 'Ошибка загрузки звонков СМП',
    );
  }

  // Вспомогательные методы
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  ApiError _handleDioError(DioException e, String defaultMessage) {
    if (e.response != null) {
      return ApiError(
        statusCode: e.response!.statusCode,
        message: e.response!.data['message'] ?? e.message ?? defaultMessage,
        rawError: e.response!.data,
      );
    } else {
      return ApiError(message: e.message ?? defaultMessage);
    }
  }

  Future<T> _handleApiCall<T>(
    Future<T> Function() apiCall, {
    required String errorMessage,
  }) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      throw _handleDioError(e, errorMessage);
    } catch (e) {
      throw ApiError(message: '$errorMessage: ${e.toString()}');
    }
  }
}

class ApiError implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, dynamic>? rawError;

  ApiError({
    this.statusCode,
    required this.message,
    this.rawError,
  });

  @override
  String toString() => 'ApiError [status: ${statusCode ?? "N/A"}]: $message';
}