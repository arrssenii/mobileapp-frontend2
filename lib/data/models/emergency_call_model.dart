// data/models/emergency_call_model.dart
class EmergencyCall {
  final int id;
  final int patientId;
  final String patientName;
  final DateTime birthDate;
  final bool isMale;
  final String? address;
  final String? phone;
  final String? diagnosis;
  final String? recommendations;
  final DateTime? callTime;

  EmergencyCall({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.birthDate,
    required this.isMale,
    this.address,
    this.phone,
    this.diagnosis,
    this.recommendations,
    this.callTime,
  });

  factory EmergencyCall.fromJson(Map<String, dynamic> json) {
    return EmergencyCall(
      id: json['id'] as int? ?? 0,
      patientId: json['patientId'] as int? ?? 0,
      patientName: json['patientName'] as String? ?? 'Неизвестный пациент',
      birthDate: DateTime.parse(json['birthDate'] as String? ?? DateTime.now().toString()),
      isMale: json['isMale'] as bool? ?? true,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      diagnosis: json['diagnosis'] as String?,
      recommendations: json['recommendations'] as String?,
      callTime: json['callTime'] != null 
          ? DateTime.parse(json['callTime'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'birthDate': birthDate.toIso8601String(),
      'isMale': isMale,
      'address': address,
      'phone': phone,
      'diagnosis': diagnosis,
      'recommendations': recommendations,
      'callTime': callTime?.toIso8601String(),
    };
  }
}
