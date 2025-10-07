import 'package:equatable/equatable.dart';

class PatientAllergy extends Equatable {
  final int id;
  final int allergyId;
  final int patientId;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PatientAllergy({
    required this.id,
    required this.allergyId,
    required this.patientId,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        allergyId,
        patientId,
        description,
        createdAt,
        updatedAt,
      ];
}