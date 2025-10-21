import '../repositories/allergy_repository.dart';

class AddPatientAllergy {
  final AllergyRepository repository;

  AddPatientAllergy(this.repository);

  Future<void> call({
    required int patientId,
    required int allergyId,
    required String description,
  }) async {
    return await repository.addPatientAllergy(
      patientId,
      allergyId,
      description,
    );
  }
}
