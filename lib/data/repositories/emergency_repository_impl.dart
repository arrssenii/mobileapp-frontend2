import '../../domain/repositories/emergency_repository.dart';
import '../../domain/entities/emergency_reception.dart';
import '../../domain/entities/emergency_reception_med_service.dart';
import '../datasources/emergency_remote_data_source.dart';
import '../../core/error/exceptions.dart';

class EmergencyReceptionRepositoryImpl implements EmergencyReceptionRepository {
  final EmergencyRemoteDataSource remoteDataSource;

  EmergencyReceptionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<EmergencyReception> createEmergencyReception({
    required int doctorId,
    required int patientId,
    required bool priority,
    required String address,
    required DateTime date,
  }) async {
    try {
      return await remoteDataSource.createEmergencyReception(
        doctorId: doctorId,
        patientId: patientId,
        priority: priority,
        address: address,
        date: date,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create emergency reception',
        statusCode: 500,
      );
    }
  }

  @override
  Future<EmergencyReception> updateEmergencyStatus(
    int receptionId, 
    EmergencyStatus status
  ) async {
    try {
      return await remoteDataSource.updateEmergencyStatus(
        receptionId,
        status.name,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update emergency status',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<EmergencyReception>> getEmergencyReceptionsByDoctor(
    int doctorId,
    {DateTime? date}
  ) async {
    try {
      return await remoteDataSource.getEmergencyReceptionsByDoctor(
        doctorId,
        date: date,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get emergency receptions',
        statusCode: 500,
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
      return await remoteDataSource.addMedServiceToReception(
        receptionId,
        medServiceId,
        diagnosis,
        recommendations,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to add medical service',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<EmergencyReceptionMedService>> getReceptionMedServices(
    int receptionId
  ) {
    // TODO: реализовать получение медицинских услуг для приема
    throw UnimplementedError();
  }
}