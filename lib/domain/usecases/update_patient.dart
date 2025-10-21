import '../repositories/patient_repository.dart';
import '../entities/patient.dart';

class UpdatePatient {
  final PatientRepository repository;

  UpdatePatient(this.repository);

  Future<Patient> call({
    required int id,
    required String fullName,
    required DateTime birthDate,
    required bool isMale,
  }) async {
    return await repository.updatePatient(
      id: id,
      fullName: fullName,
      birthDate: birthDate,
      isMale: isMale,
    );
  }
}
