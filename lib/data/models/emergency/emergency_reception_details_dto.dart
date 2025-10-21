import '../../../domain/entities/patient.dart';
import '../../../domain/entities/emergency_reception_med_service.dart';

class EmergencyReceptionDetailsDTO {
  final Patient patient;
  final String diagnosis;
  final String recommendations;

  EmergencyReceptionDetailsDTO({
    required this.patient,
    required this.diagnosis,
    required this.recommendations,
  });

  factory EmergencyReceptionDetailsDTO.fromJson(Map<String, dynamic> json) {
    return EmergencyReceptionDetailsDTO(
      patient: Patient.fromJson(json['patient']),
      diagnosis: json['diagnosis'],
      recommendations: json['recommendations'],
    );
  }

  EmergencyReceptionMedService toEntity(int emergencyReceptionId, int medServiceId) {
    return EmergencyReceptionMedService(
      id: 0, // ID будет присвоен на сервере
      emergencyReceptionId: emergencyReceptionId,
      medServiceId: medServiceId,
      diagnosis: diagnosis,
      recommendations: recommendations,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
