// lib/services/patient_service.dart
import '../services/api_client.dart';

class PatientService {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> getPatientsByDoctor(String docId) async {
    return _api.getPatientsByDoctorId(docId);
  }

  Future<List<dynamic>> getAllPatients() async {
    return _api.getAllPatients();
  }
}