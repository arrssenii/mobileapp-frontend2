import '../repositories/emergency_repository.dart';
import '../entities/emergency_reception.dart';

class GetDoctorEmergencies {
  final EmergencyReceptionRepository repository;

  GetDoctorEmergencies(this.repository);

  Future<List<EmergencyReception>> call(
    int doctorId,
    {DateTime? date}
  ) async {
    return await repository.getEmergencyReceptionsByDoctor(
      doctorId,
      date: date,
    );
  }
}