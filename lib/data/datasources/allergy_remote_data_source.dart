import 'package:dio/dio.dart';
import '../models/allergy_dto.dart';
import '../models/add_allergy_request_dto.dart';
import '../../core/error/exceptions.dart';

abstract class AllergyRemoteDataSource {
  Future<List<AllergyDTO>> getAllergies();
  Future<void> addPatientAllergy(AddAllergyRequestDTO request);
  Future<List<AllergyDTO>> getPatientAllergies(int patientId);
}

class AllergyRemoteDataSourceImpl implements AllergyRemoteDataSource {
  final Dio dio;

  AllergyRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AllergyDTO>> getAllergies() async {
    try {
      final response = await dio.get('/allergies');
      return (response.data as List)
          .map((json) => AllergyDTO.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to load allergies',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> addPatientAllergy(AddAllergyRequestDTO request) async {
    try {
      await dio.post(
        '/patient-allergies',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to add allergy',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<AllergyDTO>> getPatientAllergies(int patientId) async {
    try {
      final response = await dio.get('/patients/$patientId/allergies');
      return (response.data as List)
          .map((json) => AllergyDTO.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to load patient allergies',
        statusCode: e.response?.statusCode,
      );
    }
  }
}