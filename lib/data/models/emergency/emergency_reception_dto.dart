import '../../../domain/entities/emergency_reception.dart';

class EmergencyReceptionDTO {
  final int id;
  final int doctor_id;
  final int patient_id;
  final String status;
  final bool priority;
  final String address;
  final String date;
  final String created_at;
  final String updated_at;

  EmergencyReceptionDTO({
    required this.id,
    required this.doctor_id,
    required this.patient_id,
    required this.status,
    required this.priority,
    required this.address,
    required this.date,
    required this.created_at,
    required this.updated_at,
  });

  factory EmergencyReceptionDTO.fromJson(Map<String, dynamic> json) {
    return EmergencyReceptionDTO(
      id: json['id'],
      doctor_id: json['doctor_id'],
      patient_id: json['patient_id'],
      status: json['status'],
      priority: json['priority'],
      address: json['address'],
      date: json['date'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  EmergencyReception toEntity() {
    return EmergencyReception(
      id: id,
      doctorId: doctor_id,
      patientId: patient_id,
      status: EmergencyStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => EmergencyStatus.scheduled,
      ),
      priority: priority,
      address: address,
      date: DateTime.parse(date),
      createdAt: DateTime.parse(created_at),
      updatedAt: DateTime.parse(updated_at),
    );
  }
}