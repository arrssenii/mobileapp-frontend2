import '../../../domain/entities/patient.dart';

class ShortPatientResponseDTO {
  final int id;
  final String full_name;
  final String birth_date;
  final bool is_male;
  final String created_at;
  final String updated_at;

  ShortPatientResponseDTO({
    required this.id,
    required this.full_name,
    required this.birth_date,
    required this.is_male,
    required this.created_at,
    required this.updated_at,
  });

  factory ShortPatientResponseDTO.fromJson(Map<String, dynamic> json) {
    return ShortPatientResponseDTO(
      id: json['id'],
      full_name: json['full_name'],
      birth_date: json['birth_date'],
      is_male: json['is_male'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  Patient toEntity() {
    return Patient(
      id: id,
      fullName: full_name,
      birthDate: DateTime.parse(birth_date),
      isMale: is_male,
      personalInfoId: null,
      contactInfoId: null,
      createdAt: DateTime.parse(created_at),
      updatedAt: DateTime.parse(updated_at),
    );
  }
}