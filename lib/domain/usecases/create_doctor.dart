import '../repositories/doctor_repository.dart';
import '../entities/doctor.dart';

class CreateDoctor {
  final DoctorRepository repository;

  CreateDoctor(this.repository);

  Future<Doctor> call({
    required String fullName,
    required String login,
    required String email,
    required String password,
    required String specialization,
  }) async {
    return await repository.createDoctor(
      fullName: fullName,
      login: login,
      email: email,
      password: password,
      specialization: specialization,
    );
  }
}
