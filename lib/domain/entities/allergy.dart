class Allergy {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Allergy({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Allergy &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
