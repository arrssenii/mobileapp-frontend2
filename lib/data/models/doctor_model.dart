class Doctor {
  final int id;
  final String createdAt;
  final String updatedAt;
  final String phone;
  final Specialization specialization;

  Doctor({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.phone,
    required this.specialization,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      phone: json['phone'] as String,
      specialization: Specialization.fromJson(json['specialization']),
    );
  }

  String get fullTitle => "Доктор $phone (${specialization.title})";
}

class Specialization {
  final int id;
  final String title;

  Specialization({required this.id, required this.title});

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}
