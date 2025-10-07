class UpdateDoctorRequestDTO {
  final int id;
  final String full_name;
  final String login;
  final String email;
  final String password;
  final String specialization;

  UpdateDoctorRequestDTO({
    required this.id,
    required this.full_name,
    required this.login,
    required this.email,
    required this.password,
    required this.specialization,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': full_name,
        'login': login,
        'email': email,
        'password': password,
        'specialization': specialization,
      };
}