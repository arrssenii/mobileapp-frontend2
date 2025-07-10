class AddAllergyRequestDTO {
  final int patient_id;
  final int allergy_id;
  final String description;

  AddAllergyRequestDTO({
    required this.patient_id,
    required this.allergy_id,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patient_id,
      'allergy_id': allergy_id,
      'description': description,
    };
  }
}