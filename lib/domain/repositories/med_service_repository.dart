import '../entities/med_service.dart';

abstract class MedServiceRepository {
  Future<List<MedService>> getAllMedServices();
  Future<MedService> getMedServiceById(int id);
}
