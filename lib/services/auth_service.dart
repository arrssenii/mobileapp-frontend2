import '../services/api_client.dart';

class PatientService {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> getPatientsByDoctor(String docId) async {
    // Добавьте логику фильтрации по docId здесь, если требуется
    return _api.getAllPatients();
  }

  Future<List<dynamic>> getAllPatients() async {
    return _api.getAllPatients();
  }
}