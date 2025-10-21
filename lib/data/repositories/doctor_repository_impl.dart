import '../../domain/repositories/doctor_repository.dart';
import '../../domain/entities/doctor.dart';
import '../datasources/doctor_remote_data_source.dart';
import '../models/doctor/create_doctor_request_dto.dart';
import '../../core/error/exceptions.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;

  DoctorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Doctor> createDoctor({
    required String fullName,
    required String login,
    required String email,
    required String password,
    required String specialization,
  }) async {
    try {
      return await remoteDataSource.createDoctor(
        CreateDoctorRequestDTO(
          full_name: fullName,
          login: login,
          email: email,
          password: password,
          specialization: specialization,
        ),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create doctor',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Doctor> getDoctor(int id) async {
    try {
      return await remoteDataSource.getDoctor(id);
    } catch (e) {
      throw ServerException(
        message: 'Failed to get doctor',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Doctor> updateDoctor(Doctor doctor) {
    // TODO: реализовать обновление
    throw UnimplementedError();
  }

  @override
  Future<List<Doctor>> getAllDoctors() {
    // TODO: реализовать получение всех врачей
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDoctor(int id) {
    // TODO: реализовать удаление
    throw UnimplementedError();
  }
}
