import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../data/models/doctor_model.dart';
import 'package:http_parser/http_parser.dart';

class ApiClient {
  late Dio _dio;
  String? _authToken;
  Doctor? _currentDoctor;
  final AuthService _authService;

  final String baseUrl = 'http://192.168.29.158:65323/api/v1'; // новая
  // final String baseUrl = 'https://devapp2.kvant-cloud.ru/api/v1'; // новая с сертификатом
  // final String baseUrl = 'http://192.168.30.139:8080/api/v1'; // localhost

  ApiClient(this._authService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        //   headers: {
        //   'Content-Type': 'application/json',
        //   'Accept': 'application/json',
        // },
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

  // Получить подпись пациента (base64)
  Future<String?> getPatientSignature(String receptionId) async {
    return _handleApiCall(() async {
      final response = await _dio.get(
        '/emergency/signature/$receptionId',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 404) {
        // У пациента нет подписи — это не ошибка
        return null;
      }

      if (response.statusCode != 200) {
        throw ApiError(
          statusCode: response.statusCode,
          message: 'Ошибка загрузки подписи пациента',
          rawError: response.data,
        );
      }

      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw ApiError(
          statusCode: response.statusCode,
          message: 'Некорректный формат ответа: отсутствует data',
          rawError: response.data,
        );
      }

      return data['signatureBase64'] as String?;
    }, errorMessage: 'Ошибка при загрузке подписи пациента');
  }

  // Отправка подписи на сервер
  Future<void> uploadReceptionSignature({
    required String receptionId,
    required Uint8List signatureBytes,
  }) async {
    final formData = FormData.fromMap({
      'signature': MultipartFile.fromBytes(
        signatureBytes,
        filename: 'signature.png', // или jpg
        contentType: MediaType('image', 'png'),
      ),
    });

    await _handleApiCall(() async {
      final response = await _dio.post(
        '/emergency/signature/$receptionId',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode != 200) {
        throw ApiError(
          statusCode: response.statusCode,
          message: 'Ошибка отправки подписи',
          rawError: response.data,
        );
      }
    }, errorMessage: 'Ошибка при отправке подписи');
  }

  // Получение PDF с сервера
  Future<Uint8List> getReceptionPdf(String receptionId) async {
    return _handleApiCall(() async {
      final response = await _dio.get(
        '/emergency/pdf/$receptionId',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode != 200) {
        throw ApiError(
          statusCode: response.statusCode,
          message: 'Ошибка загрузки PDF',
          rawError: response.data,
        );
      }

      return response.data as Uint8List;
    }, errorMessage: 'Ошибка при загрузке PDF');
  }

  // Отправка подписанного PDF на сервер с подписью
  Future<void> uploadSignedPdf({
    required Uint8List pdfBytes,
    required String receptionId,
    required String filename,
    Uint8List? signatureBytes, // подпись optional
  }) async {
    return _handleApiCall(() async {
      final formDataMap = {
        'file': MultipartFile.fromBytes(pdfBytes, filename: filename),
      };

      // если есть подпись, добавляем её в formData
      if (signatureBytes != null) {
        formDataMap['signature'] = MultipartFile.fromBytes(
          signatureBytes,
          filename: 'signature.png',
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _dio.post(
        '/emergency/pdf/$receptionId',
        data: formData,
      );

      if (response.statusCode != 200) {
        throw ApiError(
          statusCode: response.statusCode,
          message: 'Ошибка отправки PDF',
          rawError: response.data,
        );
      }

      return response.data;
    }, errorMessage: 'Ошибка при отправке подписанного PDF');
  }

  Future<Map<String, dynamic>> createEmergencyCall({
    required int doctorId,
    required String address,
    required String phone,
    required bool emergency,
    required String description,
  }) async {
    return _handleApiCall(() async {
      final data = {
        "doctor_id": doctorId,
        "address": address,
        "phone": phone,
        "emergency": emergency,
        "description": description,
      };

      final response = await _dio.post(
        '/emergency/smp',
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );

      return response.data as Map<String, dynamic>;
    }, errorMessage: 'Ошибка создания вызова');
  }

  void setCurrentDoctor(Doctor doctor) {
    _currentDoctor = doctor;
    debugPrint('✅ Доктор установлен: ID=${doctor.id}');
  }

  Future<String?> getToken() async {
    return await _authService.getToken();
  }

  Future<String> getAppVersion() async {
    try {
      final response = await _dio.get('/version');
      return response.data['version'] ?? 'N/A';
    } catch (e) {
      debugPrint('Ошибка получения версии: $e');
      return 'N/A';
    }
  }

  Future<void> _loadToken() async {
    _authToken = await _authService.getToken();
    if (_authToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_authToken';

      // Загружаем ID доктора
      final doctorId = await _authService.getDoctorId();
      if (doctorId != null) {
        try {
          // TODO: Загружаем полные данные доктора когда будет готов API
          // final doctorData = await getDoctorById(doctorId);
          // _currentDoctor = Doctor.fromJson(doctorData);
          // debugPrint('🔄 Данные доктора загружены из хранилища: ${_currentDoctor!.fullTitle}');
          debugPrint('🔄 ID доктора загружен из хранилища: $doctorId');
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
    return _handleApiCall(() async {
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
    }, errorMessage: 'Ошибка загрузки деталей приёма');
  }

  Future<Map<String, dynamic>> loginDoctor(
    Map<String, dynamic> credentials,
  ) async {
    try {
      final response = await _dio.post('/auth/', data: credentials);
      print('Auth URL: ${response.realUri}');
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        Map<String, dynamic> authData;
        if (responseData.containsKey('data')) {
          authData = responseData['data'] as Map<String, dynamic>;
        } else {
          authData = responseData;
        }
        final userId = authData['id']; // userId здесь может быть int или String
        final token = authData['token'];

        if (token != null) {
          _authToken = token.toString();
          await _authService.saveToken(_authToken!); // Сохраняем токен
          _dio.options.headers['Authorization'] = 'Bearer $_authToken';

          // --- ДОБАВЬТЕ ЭТИ СТРОКИ ---
          if (userId != null) {
            // Сохраняем ID доктора в AuthService, чтобы он был доступен при перезапуске
            await _authService.saveDoctorId(
              userId.toString(),
            ); // Сохраняем как строку
            debugPrint('🔑 ID доктора сохранен в AuthService: $userId');
          }
          // --------------------------

          debugPrint('🔑 Доктор авторизован: ID=$userId');
        } else {
          // Сервер вернул 200, но токен отсутствует
          throw ApiError(
            statusCode: response.statusCode,
            message: 'Ошибка авторизации: недействительный токен',
            rawError: response.data,
          );
        }

        return responseData;
      } else {
        // Сервер вернул код ошибки (например, 400, 401, 404)
        // --- ОПРЕДЕЛЯЕМ СООБЩЕНИЕ НА ОСНОВЕ КОДА ---
        String errorMessage =
            'Неизвестная ошибка сервера (${response.statusCode})';
        if (response.statusCode == 401) {
          errorMessage = 'Неверный логин или пароль';
        } else if (response.statusCode == 404) {
          errorMessage = 'Пользователь не найден';
        } else if (response.statusCode == 400) {
          // Попробуем получить сообщение из тела ответа, если оно есть
          final serverMessage = response.data['message']?.toString();
          errorMessage = serverMessage != null
              ? 'Ошибка: $serverMessage'
              : 'Неверные данные для входа';
        }
        // Можно добавить другие коды по необходимости

        throw ApiError(
          statusCode: response.statusCode,
          message: errorMessage,
          rawError: response.data,
        );
      }
    } on DioException catch (e) {
      // --- ОШИБКА СЕТИ ИЛИ СЕРВЕРА ЧЕРЕЗ DioException ---
      String errorMessage = 'Неизвестная ошибка сети';
      int? statusCode = e.response?.statusCode;

      // Проверяем, была ли это ошибка ответа (например, 400, 401, 404)
      if (e.response != null) {
        // Это ошибка сервера (не сеть), а код состояния
        statusCode = e.response!.statusCode;
        if (statusCode == 401) {
          errorMessage = 'Неверный логин или пароль';
        } else if (statusCode == 404) {
          errorMessage = 'Пользователь не найден';
        } else if (statusCode == 400) {
          // Попробуем получить сообщение из тела ответа, если оно есть
          final serverMessage = e.response!.data['message']?.toString();
          errorMessage = serverMessage != null
              ? 'Ошибка: $serverMessage'
              : 'Неверные данные для входа';
        } else {
          // Другой код ошибки сервера
          errorMessage = 'Ошибка сервера (${statusCode})';
        }
      } else {
        // Это действительно ошибка сети (нет подключения, таймаут)
        errorMessage = 'Нет подключения к интернету';
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMessage = 'Таймаут соединения';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Ошибка подключения к серверу';
        }
      }

      throw ApiError(
        statusCode: statusCode,
        message: errorMessage,
        rawError: {
          'type': e.type.toString(),
          'request': e.requestOptions.data,
          'response': e.response?.data, // Может быть null для сетевых ошибок
          'error': e.message,
        },
      );
    }
  }

  // Вспомогательные методы форматирования
  String _formatErrorMessage(Response response) {
    final sb = StringBuffer();
    sb.writeln('Ошибка сервера (${response.statusCode})');

    if (response.data is Map) {
      response.data.forEach((key, value) {
        sb.writeln('• $key: $value');
      });
    } else {
      sb.writeln(response.data);
    }

    return sb.toString();
  }

  String _formatHeaders(Map<String, dynamic> headers) {
    return headers.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  String _formatResponse(Response? response) {
    if (response == null) return 'Нет ответа от сервера';

    return '''
  Status: ${response.statusCode}
  Headers:
  ${_formatHeaders(response.headers.map)}
  Body:
  ${response.data is String ? response.data : jsonEncode(response.data)}
  ''';
  }

  // TODO: Включить когда будет готов API для получения данных доктора
  // Future<Map<String, dynamic>> getDoctorById(String docId) async {
  //   return _handleApiCall(
  //     () async {
  //       final response = await _dio.get('/doctors/$docId');
  //
  //       if (response.statusCode != 200) {
  //         throw ApiError(
  //           statusCode: response.statusCode,
  //           message: 'Ошибка сервера: ${response.statusCode}',
  //           rawError: response.data,
  //         );
  //       }
  //
  //       // Проверяем наличие данных
  //       if (response.data == null ||
  //           response.data is! Map<String, dynamic> ||
  //           response.data['data'] == null) {
  //         throw ApiError(
  //           message: 'Неверный формат ответа',
  //           rawError: response.data,
  //         );
  //       }
  //
  //       return response.data['data'] as Map<String, dynamic>;
  //     },
  //     errorMessage: 'Ошибка получения данных доктора',
  //   );
  // }

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
      () => _dio
          .get('/users/me')
          .then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка получения данных пользователя',
    );
  }

  Future<Map<String, dynamic>> updateDoctor(
    String docId,
    Map<String, dynamic> data,
  ) async {
    return _handleApiCall(
      () => _dio
          .put('/doctors/$docId', data: data)
          .then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка обновления данных доктора',
    );
  }

  // В вашем ApiClient (или в том месте, где определён getAllPatients)
  Future<List<dynamic>> getAllPatients(
    String docId, {
    int page = 1,
    int limit = 20,
  }) async {
    return _handleApiCall(() async {
      final response = await _dio.get(
        '/patients',
        queryParameters: {'page': page, 'limit': limit},
      );

      final responseData = response.data;

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Неверный формат корневого ответа');
      }

      if (responseData.containsKey('data')) {
        final data = responseData['data'];

        if (data is List) {
          return data;
        }

        if (data is Map<String, dynamic>) {
          if (data.containsKey('Patient') && data['Patient'] is List) {
            return data['Patient'] as List;
          }
          if (data.containsKey('patient') && data['patient'] is List) {
            return data['patient'] as List;
          }
        }

        debugPrint('⚠️ Неизвестная структура внутри "data": $data');
        return [];
      }

      if (responseData.containsKey('Patient') &&
          responseData['Patient'] is List) {
        return responseData['Patient'] as List;
      }
      if (responseData.containsKey('patient') &&
          responseData['patient'] is List) {
        return responseData['patient'] as List;
      }

      debugPrint(
        '⚠️ Неизвестная структура ответа пациентов: ${responseData.keys}',
      );
      return [];
    }, errorMessage: 'Ошибка загрузки пациентов');
  }

  Future<Map<String, dynamic>> getPatientById(String patId) async {
    return _handleApiCall(() async {
      final response = await _dio.get('/patients/$patId');
      final responseData = response.data as Map<String, dynamic>;

      // Обрабатываем структуру ответа с data
      if (responseData.containsKey('data')) {
        return responseData['data'] as Map<String, dynamic>;
      }

      return responseData;
    }, errorMessage: 'Ошибка получения данных пациента');
  }

  Future<Map<String, dynamic>> createPatient(
    Map<String, dynamic> patientData,
  ) async {
    return _handleApiCall(
      () => _dio
          .post(
            '/patients/',
            data: patientData,
            options: Options(contentType: Headers.jsonContentType),
          )
          .then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка создания пациента',
    );
  }

  Future<Map<String, dynamic>> updatePatient(
    String patId,
    Map<String, dynamic> data,
  ) async {
    return _handleApiCall(
      () => _dio
          .put('/patients/$patId', data: data)
          .then((response) => response.data as Map<String, dynamic>),
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
  Future<Map<String, dynamic>> getPatientReceptionsHistory(
    String patientId,
  ) async {
    return _handleApiCall(() async {
      try {
        final response = await _dio.get(
          '/emk/$patientId',
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode == 404) {
          debugPrint(
            '⚠️ Эндпоинт истории приёмов пациента не найден (404), возвращаем пустые данные',
          );
          return {
            'data': {'hits': [], 'total': 0, 'page': 1, 'pages': 0},
          };
        }

        // Проверяем статус ответа
        if (response.statusCode != 200) {
          throw ApiError(
            statusCode: response.statusCode,
            message: 'Ошибка сервера: ${response.statusCode}',
            rawError: response.data,
          );
        }

        // ПРОВЕРЯЕМ ТОЛЬКО, ЧТО ОТВЕТ - ЭТО MAP
        if (response.data is! Map<String, dynamic>) {
          throw ApiError(
            message: 'Ответ от сервера не является объектом (Map)',
            rawError: response.data,
          );
        }

        // ВОТ ЗДЕСЬ КЛЮЧЕВОЕ ИЗМЕНЕНИЕ:
        // НЕ ПРОВЕРЯЕМ response.data['data'] на null!
        // Это нормально, если data == null — значит, истории нет.
        // Просто возвращаем response.data как есть.
        return response.data as Map<String, dynamic>;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          debugPrint(
            '⚠️ Эндпоинт истории приёмов пациента не найден (404), возвращаем пустые данные',
          );
          return {
            'data': {'hits': [], 'total': 0, 'page': 1, 'pages': 0},
          };
        }
        rethrow;
      }
    }, errorMessage: 'Ошибка загрузки истории приёмов пациента');
  }

  // Медкарты
  Future<Map<String, dynamic>> getMedCardByPatientId(String patId) async {
    return _handleApiCall(() async {
      final response = await _dio.get('/medcard/$patId');

      if (response.statusCode != 200) {
        throw ApiError(
          statusCode: response.statusCode,
          message: 'Ошибка сервера: ${response.statusCode}',
          rawError: response.data,
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      final data =
          responseData['data'] as Map<String, dynamic>? ?? responseData;

      // Преобразование данных в ожидаемый формат
      final normalized = <String, dynamic>{};

      // Основные поля
      normalized['display_name'] = data['clientName'] ?? '';
      normalized['birth_date'] = data['birthDate'] ?? '';
      normalized['age'] = data['age'];
      normalized['snils'] = data['medCardSnils'] ?? '';
      normalized['workplace'] = ''; // API не предоставляет workplace

      // Телефоны
      final phones = (data['phones'] as List<dynamic>?)?.cast<String>() ?? [];
      normalized['mobile_phone'] = phones.isNotEmpty ? phones.first : '';
      normalized['additional_phone'] = phones.length > 1 ? phones[1] : '';

      // Email
      final emails = (data['emails'] as List<dynamic>?)?.cast<String>() ?? [];
      normalized['email'] = emails.isNotEmpty ? emails.first : '';

      // Адрес
      final addresses =
          (data['addresses'] as List<dynamic>?)?.cast<String>() ?? [];
      normalized['address'] = addresses.isNotEmpty ? addresses.first : '';

      // Полисы (берём первый)
      final policies = (data['policies'] as List<dynamic>?) ?? [];
      if (policies.isNotEmpty) {
        final firstPolicy = policies.first as Map<String, dynamic>;
        normalized['policy'] = {
          'type': firstPolicy['type'] ?? '',
          'number': firstPolicy['number'] ?? '',
        };
      }

      // Сертификаты (берём первый)
      final certificates = (data['certificates'] as List<dynamic>?) ?? [];
      if (certificates.isNotEmpty) {
        final firstCert = certificates.first as Map<String, dynamic>;
        normalized['certificate'] = {
          'date': firstCert['startDate'] ?? '',
          'number': firstCert['code'] ?? '',
        };
      }

      // Лечащий врач (если есть)
      // normalized['attending_doctor'] = {...}; // если API возвращает

      // Законный представитель (если есть)
      // normalized['legal_representative'] = {...};

      // Родственник (если есть)
      // normalized['relative'] = {...};

      return normalized;
    }, errorMessage: 'Ошибка загрузки медкарты');
  }

  // Приёмы в стационаре
  Future<Map<String, dynamic>> getReceptionsHospitalByDoctorAndDate(
    String docId, {
    required DateTime date,
    int page = 1,
  }) async {
    final formattedDate = _formatDate(date);
    return _handleApiCall(() async {
      try {
        final response = await _dio.get(
          '/hospital/receptions/$docId',
          queryParameters: {'filter': 'date.eq.$formattedDate', 'page': page},
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode == 404) {
          // Если эндпоинт не найден, возвращаем пустую структуру
          debugPrint(
            '⚠️ Эндпоинт приёмов в стационаре не найден (404), возвращаем пустые данные',
          );
          return {
            'data': {'hits': [], 'total': 0, 'page': page, 'pages': 0},
          };
        }

        if (response.statusCode != 200) {
          throw ApiError(
            statusCode: response.statusCode,
            message: 'Ошибка сервера: ${response.statusCode}',
            rawError: response.data,
          );
        }

        // Возвращаем ВЕСЬ объект ответа
        return response.data as Map<String, dynamic>;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          // Если эндпоинт не найден, возвращаем пустую структуру
          debugPrint(
            '⚠️ Эндпоинт приёмов в стационаре не найден (404), возвращаем пустые данные',
          );
          return {
            'data': {'hits': [], 'total': 0, 'page': page, 'pages': 0},
          };
        }
        rethrow;
      }
    }, errorMessage: 'Ошибка загрузки приёмов в стационаре');
  }

  Future<Map<String, dynamic>> updateReceptionHospital(
    String recepId,
    Map<String, dynamic> data,
  ) async {
    return _handleApiCall(
      () => _dio
          .put('/hospital/receptions/$recepId', data: data)
          .then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка обновления приёма в стационаре',
    );
  }

  Future<Map<String, dynamic>> updateReceptionStatus(
    int receptionId, {
    required String status,
  }) async {
    return _handleApiCall(
      () => _dio
          .patch('/hospital/receptions/$receptionId', data: {'status': status})
          .then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка обновления статуса приёма',
    );
  }

  // Приёмы СМП
  Future<List<dynamic>> getReceptionsSMPByDoctorAndDate(
    String docId, {
    required DateTime date,
    int page = 1,
  }) async {
    final formattedDate = _formatDate(date);
    return _handleApiCall(() async {
      final response = await _dio.get(
        '/smp/doctors/$docId/receptions',
        queryParameters: {'date': formattedDate, 'page': page},
      );
      return response.data['data'] as List<dynamic>;
    }, errorMessage: 'Ошибка загрузки приёмов СМП');
  }

  Future<Map<String, dynamic>> getReceptionWithMedServices(String smpId) async {
    return _handleApiCall(
      () => _dio
          .get('/smp/$smpId')
          .then((response) => response.data as Map<String, dynamic>),
      errorMessage: 'Ошибка загрузки приёма СМП с услугами',
    );
  }

  Future<Map<String, dynamic>> getEmergencyCallDetails(String callId) async {
    return _handleApiCall(() async {
      final response = await _dio.get('/emergency/calls/$callId');
      return response.data as Map<String, dynamic>;
    }, errorMessage: 'Ошибка загрузки деталей вызова СМП');
  }

  // Получение данных для заключения
  Future<Map<String, dynamic>> getEmergencyConsultationData(
    String callId,
    String smpId,
  ) async {
    return _handleApiCall(() async {
      final response = await _dio.get('/emergency/smps/$callId/$smpId');
      return response.data as Map<String, dynamic>;
    }, errorMessage: 'Ошибка загрузки данных для заключения');
  }

  // Создание заключения
  Future<Map<String, dynamic>> createEmergencyReception(
    Map<String, dynamic> data,
  ) async {
    return _handleApiCall(() async {
      final response = await _dio.put(
        '/emergency/receptions',
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
      return response.data as Map<String, dynamic>;
    }, errorMessage: 'Ошибка создания заключения');
  }

  Future<Map<String, dynamic>> createEmergencyReceptionPatient({
    required int emergencyCallId,
    required String firstName,
    required String lastName,
    required String middleName,
    required DateTime birthDate,
    required bool isMale,
  }) async {
    return _handleApiCall(() async {
      final data = {
        "emergency_call_id": emergencyCallId,
        "patient": {
          "first_name": firstName,
          "last_name": lastName,
          "middle_name": middleName,
          "birth_date": DateFormat('yyyy-MM-dd').format(birthDate),
          "is_male": isMale,
        },
      };

      final response = await _dio.post(
        '/emergency/receptions',
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );

      // Явное приведение типа
      return response.data as Map<String, dynamic>;
    }, errorMessage: 'Ошибка создания пациента');
  }

  Future<Map<String, dynamic>> updateEmergencyReception({
    required int receptionId,
    required String diagnosis,
    required String recommendations,
    required Map<String, dynamic> specializationUpdates,
    required List<Map<String, dynamic>> medServices,
    required int totalCost,
  }) async {
    return _handleApiCall(() async {
      final data = {
        "diagnosis": diagnosis,
        "recommendations": recommendations,
        "specialization_data_updates": specializationUpdates,
        "med_services": medServices,
        "total_cost": totalCost,
      };

      final response = await _dio.put(
        '/emergency/receptions/$receptionId',
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
      return response.data as Map<String, dynamic>;
    }, errorMessage: 'Ошибка обновления заключения');
  }

  // Обновление статуса вызова
  Future<Map<String, dynamic>> updateEmergencyCallStatus(
    String callId,
    String status,
  ) async {
    return _handleApiCall(() async {
      final response = await _dio.patch(
        '/emergency/$callId',
        data: {'status': status},
      );
      return response.data as Map<String, dynamic>;
    }, errorMessage: 'Ошибка обновления статуса вызова');
  }

  // Получение вызовов для доктора
  Future<Map<String, dynamic>> getEmergencyCallsByDoctorAndDate(
    String doctorCode,
  ) async {
    return _handleApiCall(() async {
      final response = await _dio.get('/smp/call/$doctorCode');
      return response.data as Map<String, dynamic>;
    }, errorMessage: 'Ошибка загрузки вызовов для доктора');
  }

  // Получение шаблонов по кодам
  Future<Map<String, dynamic>> getTemplatesByCodes(
    List<String> templateCodes,
  ) async {
    return _handleApiCall(() async {
      final response = await _dio.get(
        '/smp/templates',
        queryParameters: {'codes': templateCodes.join(',')},
      );
      return response.data as Map<String, dynamic>;
    }, errorMessage: 'Ошибка загрузки шаблонов');
  }

  // Получение полной номенклатуры
  Future<Map<String, dynamic>> getFullNomenclature() async {
    return _handleApiCall(() async {
      final response = await _dio.get('/smp/nomenclature');
      return response.data as Map<String, dynamic>;
    }, errorMessage: 'Ошибка загрузки номенклатуры');
  }

  // Создание визита в 1С
  Future<Map<String, dynamic>> createVisitIn1C(
    Map<String, dynamic> data,
  ) async {
    return _handleApiCall(() async {
      final response = await _dio.post('/smp/send', data: data);
      return response.data as Map<String, dynamic>;
    }, errorMessage: 'Ошибка создания визита в 1С');
  }

  // Подтверждение получения вызова
  Future<Map<String, dynamic>> acknowledgeCallDelivery(
    String callNumber,
  ) async {
    return _handleApiCall(() async {
      final response = await _dio.post('/smp/call/$callNumber/ack');
      return response.data as Map<String, dynamic>;
    }, errorMessage: 'Ошибка подтверждения получения вызова');
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

  ApiError({this.statusCode, required this.message, this.rawError});

  @override
  String toString() => 'ApiError [status: ${statusCode ?? "N/A"}]: $message';
}
