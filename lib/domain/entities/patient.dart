import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final int id;
  final String fullName;
  final DateTime birthDate;
  final bool isMale;
  final int? personalInfoId;
  final int? contactInfoId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Patient({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.isMale,
    this.personalInfoId,
    this.contactInfoId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Добавляем фабричный метод fromJson
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      fullName: json['full_name'],
      birthDate: DateTime.parse(json['birth_date']),
      isMale: json['is_male'],
      personalInfoId: json['personal_info_id'],
      contactInfoId: json['contact_info_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get gender => isMale ? 'Мужской' : 'Женский';
  String get formattedBirthDate => '${birthDate.day}.${birthDate.month}.${birthDate.year}';

  @override
  List<Object?> get props => [
        id,
        fullName,
        birthDate,
        isMale,
        personalInfoId,
        contactInfoId,
        createdAt,
        updatedAt,
      ];
}
