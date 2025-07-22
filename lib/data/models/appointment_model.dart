enum AppointmentStatus {
  scheduled,  // Запланирован
  completed,  // Приём завершен
  noShow,     // Не явился
}

class Appointment {
  final int id;
  final int patientId; // Добавляем ID пациента
  final String patientName;
  final String diagnosis;
  final String address;
  final DateTime time;
  AppointmentStatus status;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.diagnosis,
    required this.address,
    required this.time,
    this.status = AppointmentStatus.scheduled,
  });
}