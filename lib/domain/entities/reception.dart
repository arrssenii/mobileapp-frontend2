enum ReceptionStatus {
  scheduled, // Запланирован
  completed, // Завершен
  cancelled, // Отменен
  noShow,    // Не явился
}

class Reception {
  final int id;
  final int doctorId;
  final int patientId;
  final DateTime date;
  final String? diagnosis;
  final String? recommendations;
  final bool isOut;
  final ReceptionStatus status;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reception({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.date,
    this.diagnosis,
    this.recommendations,
    required this.isOut,
    required this.status,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });
}