import '../repositories/med_service_repository.dart';
import '../entities/med_service.dart';

class GetMedServices {
  final MedServiceRepository repository;

  GetMedServices(this.repository);

  Future<List<MedService>> call() async {
    return await repository.getAllMedServices();
  }
}
