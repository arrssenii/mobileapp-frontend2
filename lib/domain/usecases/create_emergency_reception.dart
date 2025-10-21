import '../repositories/emergency_repository.dart';
import '../entities/emergency_reception.dart';

class CreateEmergencyReception {
  final EmergencyReceptionRepository repository;

  CreateEmergencyReception(this.repository);

  Future<EmergencyReception> call({
    required int doctorId,
    required int patientId,
    required bool priority,
    required String address,
    required DateTime date,
  }) async {
    return await repository.createEmergencyReception(
      doctorId: doctorId,
      patientId: patientId,
      priority: priority,
      address: address,
      date: date,
    );
  }
}
