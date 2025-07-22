// data/models/patient_model.dart
class Patient {
  final int id;
  final String fullName;
  final DateTime birthDate;
  final bool isMale;
  final String snils;
  final String oms;
  final String passportSeries; // Новое поле: серия паспорта
  final String passportNumber; // Новое поле: номер паспорта
  final String phone;
  final String email;
  final String address;
  final List<String> allergies;
  final String? diagnosis;

  Patient({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.isMale,
    required this.snils,
    required this.oms,
    required this.passportSeries, // Обновлено
    required this.passportNumber, // Обновлено
    required this.phone,
    required this.email,
    required this.address,
    required this.allergies,
    this.diagnosis,
  });

  factory Patient.fromMedCardJson(Map<String, dynamic> json) {
    final data = json['data'];
    final patientData = data['patient'];
    final personalInfo = data['personal_info'] ?? {};
    final contactInfo = data['contact_info'] ?? {};
    String passportSeries = '';
    String passportNumber = '';
    final passport = personalInfo['passport_series'] ?? '';
    
    if (passport.isNotEmpty) {
      // Пытаемся разделить серию и номер
      final parts = passport.split(' ');
      if (parts.length >= 2) {
        passportSeries = parts[0];
        passportNumber = parts[1];
      } else if (passport.length == 10) {
        // Формат 1234567890 -> 1234 567890
        passportSeries = passport.substring(0, 4);
        passportNumber = passport.substring(4);
      } else {
        // Неизвестный формат - оставляем как есть в серии
        passportSeries = passport;
      }
    }
    
    return Patient(
      id: patientData['id'],
      fullName: patientData['full_name'] ?? 'Неизвестно',
      birthDate: DateTime.parse(patientData['birth_date']),
      isMale: patientData['is_male'] ?? true,
      snils: personalInfo['snils'] ?? '',
      oms: personalInfo['oms'] ?? '',
      passportSeries: passportSeries,
      passportNumber: passportNumber,
      phone: contactInfo['phone'] ?? '',
      email: contactInfo['email'] ?? '',
      address: contactInfo['address'] ?? '',
      allergies: (data['allergy'] as List? ?? [])
          .map<String>((item) => item['name'] as String? ?? '')
          .toList(),
      diagnosis: data['diagnosis'] as String?,
    );
  }

  String get formattedBirthDate => 
    '${birthDate.day.toString().padLeft(2, '0')}.'
    '${birthDate.month.toString().padLeft(2, '0')}.'
    '${birthDate.year}';

  String get passportFull {
    if (passportSeries.isEmpty && passportNumber.isEmpty) return '';
    return '$passportSeries $passportNumber';
  }

  String get gender => isMale ? 'Мужской' : 'Женский';
}