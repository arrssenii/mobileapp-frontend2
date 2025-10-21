import '../../../domain/entities/allergy.dart'; // или соответствующий путь


class AllergyDTO {
  final int id;
  final String name;
  final String created_at;
  final String updated_at;

  AllergyDTO({
    required this.id,
    required this.name,
    required this.created_at,
    required this.updated_at,
  });

  factory AllergyDTO.fromJson(Map<String, dynamic> json) {
    return AllergyDTO(
      id: json['id'],
      name: json['name'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  Allergy toEntity() {
    return Allergy(
      id: id,
      name: name,
      createdAt: DateTime.parse(created_at),
      updatedAt: DateTime.parse(updated_at),
    );
  }
}
