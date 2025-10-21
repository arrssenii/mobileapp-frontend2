class EmergencyReceptionMedService {
  final int id;
  final int emergencyReceptionId;
  final int medServiceId;
  final String diagnosis;
  final String recommendations;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmergencyReceptionMedService({
    required this.id,
    required this.emergencyReceptionId,
    required this.medServiceId,
    required this.diagnosis,
    required this.recommendations,
    required this.createdAt,
    required this.updatedAt,
  });
}
