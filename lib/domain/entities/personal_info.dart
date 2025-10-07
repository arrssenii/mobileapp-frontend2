class PersonalInfo {
  final int id;
  final int patientId;
  final String passportSeries;
  final String snils;
  final String oms;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PersonalInfo({
    required this.id,
    required this.patientId,
    required this.passportSeries,
    required this.snils,
    required this.oms,
    required this.createdAt,
    required this.updatedAt,
  });
}
