import '../../domain/entities/contact_info.dart';

class ContactInfoResponseDTO {
  final String phone;
  final String email;
  final String address;

  ContactInfoResponseDTO({
    required this.phone,
    required this.email,
    required this.address,
  });

  factory ContactInfoResponseDTO.fromJson(Map<String, dynamic> json) {
    return ContactInfoResponseDTO(
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
    );
  }

  ContactInfo toEntity({
    required int id,
    required int patientId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return ContactInfo(
      id: id,
      patientId: patientId,
      phone: phone,
      email: email,
      address: address,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}