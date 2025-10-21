import '../repositories/allergy_repository.dart';
import '../entities/allergy.dart';

class GetAllergies {
  final AllergyRepository repository;

  GetAllergies(this.repository);

  Future<List<Allergy>> call() async {
    return await repository.getAllergies();
  }
}
