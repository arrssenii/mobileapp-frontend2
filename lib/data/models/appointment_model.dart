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
  final DateTime birthDate; // Добавим дату рождения
  final bool isMale;
  AppointmentStatus status;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.diagnosis,
    required this.address,
    required this.time,
    required this.birthDate,
    required this.isMale,
    this.status = AppointmentStatus.scheduled,
  });
}