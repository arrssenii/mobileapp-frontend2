import 'medical_card_model.dart';

class PatientApiModel {
  final String birthDate;
  final String fullName;
  final bool gender;
  final int id;
  final MedicalCard? medicalCard;
  final String patientID;

  PatientApiModel({
    required this.birthDate,
    required this.fullName,
    required this.gender,
    required this.id,
    this.medicalCard,
    required this.patientID,
  });

  factory PatientApiModel.fromJson(Map<String, dynamic> json) {
    return PatientApiModel(
      birthDate: json['birthDate'] as String,
      fullName: json['fullName'] as String,
      gender: json['gender'] as bool,
      id: json['id'] as int,
      medicalCard: json['medical_card'] != null
          ? MedicalCard.fromJson(json['medical_card'] as Map<String, dynamic>)
          : null,
      patientID: json['patientID'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'birthDate': birthDate,
      'fullName': fullName,
      'gender': gender,
      'id': id,
      'medical_card': medicalCard?.toJson(),
      'patientID': patientID,
    };
  }

  // Вспомогательные методы для UI
  String get formattedBirthDate {
    try {
      final date = DateTime.parse(birthDate);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return birthDate;
    }
  }

  String get genderText => gender ? 'Мужской' : 'Женский';

  String get shortInfo {
    final age = _calculateAge();
    return '$fullName, $age лет, $genderText';
  }

  int _calculateAge() {
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  // Получение основных контактных данных из медкарты
  String? get phone => medicalCard?.mobilePhone ?? medicalCard?.additionalPhone;
  String? get address => medicalCard?.address;
  String? get snils => medicalCard?.snils;
}