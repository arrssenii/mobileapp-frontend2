import '../entities/allergy.dart';

abstract class AllergyRepository {
  Future<List<Allergy>> getAllergies();
  Future<void> addPatientAllergy(int patientId, int allergyId, String description);
  Future<List<Allergy>> getPatientAllergies(int patientId);
}
