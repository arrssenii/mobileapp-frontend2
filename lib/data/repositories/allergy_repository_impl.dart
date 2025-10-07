import '../../domain/repositories/allergy_repository.dart';
import '../../domain/entities/allergy.dart';
import '../../core/error/exceptions.dart';
import '../models/allergy/add_allergy_request_dto.dart';
import '../datasources/allergy_remote_data_source.dart';

class AllergyRepositoryImpl implements AllergyRepository {
  final AllergyRemoteDataSource remoteDataSource;

  AllergyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Allergy>> getAllergies() async {
    try {
      final allergies = await remoteDataSource.getAllergies();
      return allergies.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to load allergies',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> addPatientAllergy(
    int patientId,
    int allergyId,
    String description,
  ) async {
    try {
      await remoteDataSource.addPatientAllergy(
        AddAllergyRequestDTO(
          patient_id: patientId,
          allergy_id: allergyId,
          description: description,
        ),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to add allergy',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<Allergy>> getPatientAllergies(int patientId) async {
    try {
      // Предполагая, что remoteDataSource имеет соответствующий метод
      final allergies = await remoteDataSource.getPatientAllergies(patientId);
      return allergies.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to load patient allergies',
        statusCode: 500,
      );
    }
  }
}