import '../repositories/patient_repository.dart';
import '../entities/patient.dart';

class GetPatient {
  final PatientRepository repository;

  GetPatient(this.repository);

  Future<Patient> call(int id) async {
    return await repository.getPatient(id);
  }
}