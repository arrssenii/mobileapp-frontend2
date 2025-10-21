class CreatePatientRequestDTO {
  final String full_name;
  final String birth_date;
  final bool is_male;

  CreatePatientRequestDTO({
    required this.full_name,
    required this.birth_date,
    required this.is_male,
  });

  Map<String, dynamic> toJson() => {
        'full_name': full_name,
        'birth_date': birth_date,
        'is_male': is_male,
      };
}
