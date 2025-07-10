import '../repositories/patient_repository.dart';
import '../entities/patient.dart';

class SearchPatients {
  final PatientRepository repository;

  SearchPatients(this.repository);

  Future<List<Patient>> call(String query) async {
    return await repository.searchPatients(query);
  }
}