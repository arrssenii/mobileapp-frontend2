import '../entities/patient.dart';
import '../entities/patient_allergy.dart';

abstract class PatientRepository {
  Future<Patient> createPatient({
    required String fullName,
    required DateTime birthDate,
    required bool isMale,
  });
  
  Future<Patient> updatePatient({
    required int id,
    required String fullName,
    required DateTime birthDate,
    required bool isMale,
  });
  
  Future<Patient> getPatient(int id);
  Future<List<Patient>> searchPatients(String query);
  Future<List<PatientAllergy>> getPatientAllergies(int patientId);
  Future<void> deletePatient(int id);
}
