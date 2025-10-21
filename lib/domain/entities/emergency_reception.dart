enum EmergencyStatus {
  scheduled, // В ожидании
  accepted,  // Принят
  onPlace,   // На месте
  completed, // Завершен
  cancelled, // Отменен
  noShow,    // Не явился
}

class EmergencyReception {
  final int id;
  final int doctorId;
  final int patientId;
  final EmergencyStatus status;
  final bool priority; // true - экстренный, false - неотложный
  final String address;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmergencyReception({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.status,
    required this.priority,
    required this.address,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmergencyReception.fromStatusString(String status) {
    return EmergencyReception(
      id: 0,
      doctorId: 0,
      patientId: 0,
      status: EmergencyStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => EmergencyStatus.scheduled,
      ),
      priority: false,
      address: '',
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String get statusString => status.name;
}
