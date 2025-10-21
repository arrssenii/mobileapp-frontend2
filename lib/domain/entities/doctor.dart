class Doctor {
  final int id;
  final String fullName;
  final String login;
  final String email;
  final String specialization;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Doctor({
    required this.id,
    required this.fullName,
    required this.login,
    required this.email,
    required this.specialization,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Doctor &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
