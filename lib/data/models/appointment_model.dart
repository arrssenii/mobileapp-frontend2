// data/models/appointment_model.dart
import 'package:intl/intl.dart';

class Appointment {
  final int id;
  final int patientId;
  final String patientName;
  final String diagnosis;
  final String address;
  final DateTime time;
  late final AppointmentStatus status;
  final DateTime birthDate;
  final bool isMale;
  final String specialization; // Специализация врача

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.diagnosis,
    required this.address,
    required this.time,
    required this.status,
    required this.birthDate,
    required this.isMale,
    required this.specialization,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Извлекаем данные о пациенте
    final patientData = json['patient'] as Map<String, dynamic>? ?? {};
    final patientName = patientData['full_name'] as String? ?? 'Неизвестный пациент';
    final patientId = patientData['id'] as int? ?? 0;
    final isMale = patientData['is_male'] as bool? ?? true;

    // Извлекаем данные о враче
    final doctorData = json['doctor'] as Map<String, dynamic>? ?? {};
    final specialization = doctorData['specialization'] as String? ?? 'Терапевт';

    // Парсим дату приема
    DateTime parseDateTime(dynamic dateString) {
      if (dateString == null) return DateTime.now();
      try {
        // Пробуем разные форматы дат
        try {
          return DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(dateString).toLocal();
        } catch (e) {
          return DateTime.parse(dateString).toLocal();
        }
      } catch (e) {
        return DateTime.now();
      }
    }

    // Парсим дату рождения
    DateTime parseBirthDate(dynamic birthDate) {
      if (birthDate == null) return DateTime(2000);
      try {
        return DateTime.parse(birthDate).toLocal();
      } catch (e) {
        return DateTime(2000);
      }
    }

    // Парсим статус приема
    AppointmentStatus parseStatus(String status) {
      switch (status.toLowerCase()) {
        case 'completed':
          return AppointmentStatus.completed;
        case 'cancelled':
        case 'no_show':
          return AppointmentStatus.noShow;
        case 'scheduled':
        default:
          return AppointmentStatus.scheduled;
      }
    }

    // Формируем полный адрес
    String buildAddress(Map<String, dynamic> patient) {
      final address = patient['address']?.toString() ?? '';
      final city = patient['city']?.toString() ?? '';
      
      if (address.isNotEmpty && city.isNotEmpty) {
        return '$city, $address';
      } else if (address.isNotEmpty) {
        return address;
      } else if (city.isNotEmpty) {
        return city;
      }
      return 'Адрес не указан';
    }

    return Appointment(
      id: json['id'] as int? ?? 0,
      patientId: patientId,
      patientName: patientName,
      diagnosis: json['diagnosis'] as String? ?? 'Диагноз не указан',
      address: buildAddress(patientData),
      time: parseDateTime(json['date']),
      status: parseStatus(json['status'] as String? ?? 'scheduled'),
      birthDate: parseBirthDate(patientData['birth_date']),
      isMale: isMale,
      specialization: specialization, // Важное поле для форм
    );
  }
}

enum AppointmentStatus {
  scheduled,
  completed,
  noShow,
}