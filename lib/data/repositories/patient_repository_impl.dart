import '../../domain/repositories/patient_repository.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/patient_allergy.dart';
import '../datasources/patient_remote_data_source.dart';
import '../models/patient/create_patient_request_dto.dart';
import '../models/patient/update_patient_request_dto.dart';
import '../../core/error/exceptions.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Patient> createPatient({
    required String fullName,
    required DateTime birthDate,
    required bool isMale,
  }) async {
    try {
      return await remoteDataSource.createPatient(
        CreatePatientRequestDTO(
          full_name: fullName,
          birth_date: birthDate.toIso8601String(),
          is_male: isMale,
        ),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create patient',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Patient> updatePatient({
    required int id,
    required String fullName,
    required DateTime birthDate,
    required bool isMale,
  }) async {
    try {
      return await remoteDataSource.updatePatient(
        UpdatePatientRequestDTO(
          id: id,
          full_name: fullName,
          birth_date: birthDate.toIso8601String(),
          is_male: isMale,
        ),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update patient',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Patient> getPatient(int id) async {
    try {
      return await remoteDataSource.getPatient(id);
    } catch (e) {
      throw ServerException(
        message: 'Failed to get patient',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<Patient>> searchPatients(String query) async {
    try {
      return await remoteDataSource.searchPatients(query);
    } catch (e) {
      throw ServerException(
        message: 'Failed to search patients',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<PatientAllergy>> getPatientAllergies(int patientId) {
    // TODO: реализовать получение аллергий пациента
    throw UnimplementedError();
  }

  @override
  Future<void> deletePatient(int id) {
    // TODO: реализовать удаление пациента
    throw UnimplementedError();
  }
}
