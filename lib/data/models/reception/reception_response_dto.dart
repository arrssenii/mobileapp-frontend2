import '../../../domain/entities/reception.dart';

class ReceptionResponseDTO {
  final int doctor_id;
  final int patient_id;
  final String date;
  final String? diagnosis;
  final String? recommendations;
  final bool is_out;
  final String status;
  final String address;

  ReceptionResponseDTO({
    required this.doctor_id,
    required this.patient_id,
    required this.date,
    this.diagnosis,
    this.recommendations,
    required this.is_out,
    required this.status,
    required this.address,
  });

  factory ReceptionResponseDTO.fromJson(Map<String, dynamic> json) {
    return ReceptionResponseDTO(
      doctor_id: json['doctor_id'],
      patient_id: json['patient_id'],
      date: json['date'],
      diagnosis: json['diagnosis'],
      recommendations: json['recommendations'],
      is_out: json['is_out'],
      status: json['status'],
      address: json['address'],
    );
  }

  Reception toEntity() {
    return Reception(
      id: 0, // Will be set by server
      doctorId: doctor_id,
      patientId: patient_id,
      date: DateTime.parse(date),
      diagnosis: diagnosis,
      recommendations: recommendations,
      isOut: is_out,
      status: _parseStatus(status),
      address: address,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  ReceptionStatus _parseStatus(String status) {
    switch (status) {
      case 'scheduled': return ReceptionStatus.scheduled;
      case 'completed': return ReceptionStatus.completed;
      case 'cancelled': return ReceptionStatus.cancelled;
      case 'no_show': return ReceptionStatus.noShow;
      default: return ReceptionStatus.scheduled;
    }
  }
}