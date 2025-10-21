import '../../../domain/entities/doctor.dart';

class DoctorResponseDTO {
  final int id;
  final String full_name;
  final String login;
  final String email;
  final String password;
  final String specialization;

  DoctorResponseDTO({
    required this.id,
    required this.full_name,
    required this.login,
    required this.email,
    required this.password,
    required this.specialization,
  });

  factory DoctorResponseDTO.fromJson(Map<String, dynamic> json) {
    return DoctorResponseDTO(
      id: json['id'],
      full_name: json['full_name'],
      login: json['login'],
      email: json['email'],
      password: json['password'],
      specialization: json['specialization'],
    );
  }

  Doctor toEntity({
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return Doctor(
      id: id,
      fullName: full_name,
      login: login,
      email: email,
      specialization: specialization,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
