class MedService {
  final int id;
  final String name;
  final int price;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedService({
    required this.id,
    required this.name,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });
}