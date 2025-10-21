import 'package:dio/dio.dart';
import '../../domain/entities/emergency_reception.dart';
import '../../domain/entities/emergency_reception_med_service.dart';
import '../models/emergency/emergency_reception_dto.dart';
import '../models/emergency/emergency_reception_med_service_dto.dart';
import '../../core/error/exceptions.dart';

abstract class EmergencyRemoteDataSource {
  Future<EmergencyReception> createEmergencyReception({
    required int doctorId,
    required int patientId,
    required bool priority,
    required String address,
    required DateTime date,
  });
  
  Future<EmergencyReception> updateEmergencyStatus(
    int receptionId, 
    String status
  );
  
  Future<List<EmergencyReception>> getEmergencyReceptionsByDoctor(
    int doctorId,
    {DateTime? date}
  );
  
  Future<EmergencyReceptionMedService> addMedServiceToReception(
    int receptionId,
    int medServiceId,
    String diagnosis,
    String recommendations,
  );
}

class EmergencyRemoteDataSourceImpl implements EmergencyRemoteDataSource {
  final Dio dio;

  EmergencyRemoteDataSourceImpl({required this.dio});

  @override
  Future<EmergencyReception> createEmergencyReception({
    required int doctorId,
    required int patientId,
    required bool priority,
    required String address,
    required DateTime date,
  }) async {
    try {
      final response = await dio.post(
        '/emergency-receptions',
        data: {
          'doctor_id': doctorId,
          'patient_id': patientId,
          'priority': priority,
          'address': address,
          'date': date.toIso8601String(),
        },
      );
      
      return EmergencyReceptionDTO.fromJson(response.data).toEntity();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to create emergency reception',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EmergencyReception> updateEmergencyStatus(
    int receptionId, 
    String status
  ) async {
    try {
      final response = await dio.patch(
        '/emergency-receptions/$receptionId/status',
        data: {'status': status},
      );
      
      return EmergencyReceptionDTO.fromJson(response.data).toEntity();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to update status',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<EmergencyReception>> getEmergencyReceptionsByDoctor(
    int doctorId,
    {DateTime? date}
  ) async {
    try {
      final response = await dio.get(
        '/doctors/$doctorId/emergency-receptions',
        queryParameters: date != null 
          ? {'date': date.toIso8601String().split('T')[0]} 
          : null,
      );
      
      return (response.data as List)
          .map((json) => EmergencyReceptionDTO.fromJson(json).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to get emergency receptions',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<EmergencyReceptionMedService> addMedServiceToReception(
    int receptionId,
    int medServiceId,
    String diagnosis,
    String recommendations,
  ) async {
    try {
      final response = await dio.post(
        '/emergency-receptions/$receptionId/med-services',
        data: {
          'med_service_id': medServiceId,
          'diagnosis': diagnosis,
          'recommendations': recommendations,
        },
      );
      
      return EmergencyReceptionMedServiceDTO.fromJson(response.data).toEntity();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to add medical service',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
