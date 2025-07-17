// lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  late Dio _dio;

  final String baseUrl = 'http://192.168.30.106:8080/api/v1';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('API Request: ${options.method} ${options.path}');
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

  // Аутентификация
  Future<Map<String, dynamic>> loginDoctor(Map<String, dynamic> credentials) async {
  try {
    final response = await _dio.post(
      '/auth',
      data: credentials,
      options: Options(
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status! < 500,
      ),
    );
    
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw ApiError(
        statusCode: response.statusCode,
        message: response.data['message'] ?? 'Ошибка авторизации',
        rawError: response.data,
      );
    }
  } on DioException catch (e) {
    if (e.response != null) {
      throw ApiError(
        statusCode: e.response!.statusCode,
        message: e.response!.data['message'] ?? e.message,
        rawError: e.response!.data,
      );
    } else {
      throw ApiError(message: e.message ?? 'Сетевая ошибка');
    }
  }
}

  // Медкарта пациента
  Future<Map<String, dynamic>> getMedCardByPatientId(String patId) async {
    final response = await _dio.get('/medcard/$patId');
    return response.data;
  }

  Future<Map<String, dynamic>> updateMedCard(String patId, Map<String, dynamic> data) async {
    final response = await _dio.put('/medcard/$patId', data: data);
    return response.data;
  }

  // Приемы СМП
  Future<List<dynamic>> getReceptionsSMPByDoctorId(String doctorId) async {
    final response = await _dio.get('/receps/$doctorId');
    return response.data['data'];
  }

  // Приемы в стационаре
  Future<List<dynamic>> getReceptionsHospitalByDoctorId(String docId) async {
    final response = await _dio.get('/recepHospital/$docId');
    return response.data['data'];
  }

  Future<List<dynamic>> getReceptionsHospitalByPatientId(String patId) async {
    final response = await _dio.get('/recepHospital/patients/$patId');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> updateReceptionHospital(String recepId, Map<String, dynamic> data) async {
    final response = await _dio.put('/recepHospital/$recepId', data: data);
    return response.data;
  }

  // Пациенты
  Future<List<dynamic>> getPatientsByDoctorId(String docId) async {
    final response = await _dio.get('/patients/$docId');
    return response.data['data'];
  }

  Future<List<dynamic>> getAllPatients() async {
    final response = await _dio.get('/patients/');
    return response.data['data'];
  }

  // СМП
  Future<List<dynamic>> getEmergencyCallsByDoctorId(String docId) async {
    final response = await _dio.get('/emergencyGroup/$docId');
    return response.data['data'];
  }

  Future<List<dynamic>> getSMPCallsByDoctorId(String docId) async {
    final response = await _dio.get('/emergencyGroup/$docId/smps');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getReceptionWithMedServices(String docId, String smpId) async {
    final response = await _dio.get('/emergencyGroup/$docId/smps/$smpId');
    return response.data;
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
  String toString() => 'ApiError [status: $statusCode]: $message';
}