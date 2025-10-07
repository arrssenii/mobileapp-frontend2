class CreateContactInfoRequestDTO {
  final int patient_id;
  final String phone;
  final String email;
  final String address;

  CreateContactInfoRequestDTO({
    required this.patient_id,
    required this.phone,
    required this.email,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        'patient_id': patient_id,
        'phone': phone,
        'email': email,
        'address': address,
      };
}