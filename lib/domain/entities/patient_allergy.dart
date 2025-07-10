class PatientAllergy {
  final int id;
  final int patientId;
  final int allergyId;
  final String description;
  final DateTime createdAt;

  const PatientAllergy({
    required this.id,
    required this.patientId,
    required this.allergyId,
    required this.description,
    required this.createdAt,
  });
}