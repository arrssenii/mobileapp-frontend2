class UpdatePatientRequestDTO {
  final int id;
  final String full_name;
  final String birth_date;
  final bool is_male;

  UpdatePatientRequestDTO({
    required this.id,
    required this.full_name,
    required this.birth_date,
    required this.is_male,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': full_name,
        'birth_date': birth_date,
        'is_male': is_male,
      };
}