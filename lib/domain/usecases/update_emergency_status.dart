import '../repositories/emergency_repository.dart';
import '../entities/emergency_reception.dart';

class UpdateEmergencyStatus {
  final EmergencyReceptionRepository repository;

  UpdateEmergencyStatus(this.repository);

  Future<EmergencyReception> call(
    int receptionId, 
    EmergencyStatus status
  ) async {
    return await repository.updateEmergencyStatus(
      receptionId,
      status,
    );
  }
}