import '../repositories/patient_repository.dart';
import '../entities/patient.dart';

class CreatePatient {
  final PatientRepository repository;

  CreatePatient(this.repository);

  Future<Patient> call({
    required String fullName,
    required DateTime birthDate,
    required bool isMale,
  }) async {
    return await repository.createPatient(
      fullName: fullName,
      birthDate: birthDate,
      isMale: isMale,
    );
  }
}