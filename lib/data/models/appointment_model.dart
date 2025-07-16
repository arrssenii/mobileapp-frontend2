enum AppointmentStatus {
  scheduled,  // Запланирован
  completed,  // Приём завершен
  noShow,     // Не явился
}

class Appointment {
  final int id;
  final String patientName;
  final String diagnosis; // Добавлено поле диагноза
  final String address;   // Добавлено поле адреса
  final DateTime time;
  AppointmentStatus status;

  Appointment({
    required this.id,
    required this.patientName,
    required this.diagnosis,
    required this.address,
    required this.time,
    this.status = AppointmentStatus.scheduled,
  });
}