import '../../domain/repositories/med_service_repository.dart';
import '../../domain/entities/med_service.dart';
import '../datasources/med_service_remote_data_source.dart';
import '../../core/error/exceptions.dart';

class MedServiceRepositoryImpl implements MedServiceRepository {
  final MedServiceRemoteDataSource remoteDataSource;

  MedServiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MedService>> getAllMedServices() async {
    try {
      return await remoteDataSource.getAllMedServices();
    } catch (e) {
      throw ServerException(
        message: 'Failed to get medical services',
        statusCode: 500,
      );
    }
  }

  @override
  Future<MedService> getMedServiceById(int id) async {
    try {
      final services = await remoteDataSource.getAllMedServices();
      return services.firstWhere((service) => service.id == id);
    } catch (e) {
      throw ServerException(
        message: 'Failed to get medical service by ID',
        statusCode: 500,
      );
    }
  }
}
