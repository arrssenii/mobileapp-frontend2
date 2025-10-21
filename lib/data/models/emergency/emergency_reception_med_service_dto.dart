import '../../../domain/entities/emergency_reception_med_service.dart';

class EmergencyReceptionMedServiceDTO {
  final int id;
  final int emergency_reception_id;
  final int med_service_id;
  final String diagnosis;
  final String recommendations;
  final String created_at;
  final String updated_at;

  EmergencyReceptionMedServiceDTO({
    required this.id,
    required this.emergency_reception_id,
    required this.med_service_id,
    required this.diagnosis,
    required this.recommendations,
    required this.created_at,
    required this.updated_at,
  });

  factory EmergencyReceptionMedServiceDTO.fromJson(Map<String, dynamic> json) {
    return EmergencyReceptionMedServiceDTO(
      id: json['id'],
      emergency_reception_id: json['emergency_reception_id'],
      med_service_id: json['med_service_id'],
      diagnosis: json['diagnosis'],
      recommendations: json['recommendations'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  EmergencyReceptionMedService toEntity() {
    return EmergencyReceptionMedService(
      id: id,
      emergencyReceptionId: emergency_reception_id,
      medServiceId: med_service_id,
      diagnosis: diagnosis,
      recommendations: recommendations,
      createdAt: DateTime.parse(created_at),
      updatedAt: DateTime.parse(updated_at),
    );
  }
}
