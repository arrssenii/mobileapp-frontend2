import 'package:dio/dio.dart';
import '../../domain/entities/patient.dart';
import '../models/patient/create_patient_request_dto.dart';
import '../models/patient/update_patient_request_dto.dart';
import '../models/patient/short_patient_response_dto.dart';
import '../../core/error/exceptions.dart';

abstract class PatientRemoteDataSource {
  Future<Patient> createPatient(CreatePatientRequestDTO request);
  Future<Patient> updatePatient(UpdatePatientRequestDTO request);
  Future<Patient> getPatient(int id);
  Future<List<Patient>> searchPatients(String query);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final Dio dio;

  PatientRemoteDataSourceImpl({required this.dio});

  @override
  Future<Patient> createPatient(CreatePatientRequestDTO request) async {
    try {
      final response = await dio.post(
        '/patients',
        data: request.toJson(),
      );
      
      return _parsePatientResponse(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to create patient',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Patient> updatePatient(UpdatePatientRequestDTO request) async {
    try {
      final response = await dio.put(
        '/patients/${request.id}',
        data: request.toJson(),
      );
      
      return _parsePatientResponse(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to update patient',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Patient> getPatient(int id) async {
    try {
      final response = await dio.get('/patients/$id');
      return _parsePatientResponse(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to get patient',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Patient>> searchPatients(String query) async {
    try {
      final response = await dio.get(
        '/patients/search',
        queryParameters: {'query': query},
      );
      
      return (response.data as List)
          .map((json) => ShortPatientResponseDTO.fromJson(json).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to search patients',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Patient _parsePatientResponse(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      fullName: json['full_name'],
      birthDate: DateTime.parse(json['birth_date']),
      isMale: json['is_male'],
      personalInfoId: json['personal_info_id'],
      contactInfoId: json['contact_info_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}