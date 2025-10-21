import '../entities/emergency_reception.dart';
import '../entities/emergency_reception_med_service.dart';

abstract class EmergencyReceptionRepository {
  Future<EmergencyReception> createEmergencyReception({
    required int doctorId,
    required int patientId,
    required bool priority,
    required String address,
    required DateTime date,
  });
  
  Future<EmergencyReception> updateEmergencyStatus(
    int receptionId, 
    EmergencyStatus status
  );
  
  Future<List<EmergencyReception>> getEmergencyReceptionsByDoctor(
    int doctorId,
    {DateTime? date}
  );
  
  Future<EmergencyReceptionMedService> addMedServiceToReception(
    int receptionId,
    int medServiceId,
    String diagnosis,
    String recommendations,
  );
  
  Future<List<EmergencyReceptionMedService>> getReceptionMedServices(
    int receptionId
  );
}
