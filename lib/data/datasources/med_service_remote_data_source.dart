import 'package:dio/dio.dart';
import '../../domain/entities/med_service.dart';
import '../../core/error/exceptions.dart';

abstract class MedServiceRemoteDataSource {
  Future<List<MedService>> getAllMedServices();
}

class MedServiceRemoteDataSourceImpl implements MedServiceRemoteDataSource {
  final Dio dio;

  MedServiceRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<MedService>> getAllMedServices() async {
    try {
      final response = await dio.get('/med-services');
      return (response.data as List).map((json) => 
        MedService(
          id: json['id'],
          name: json['name'],
          price: json['price'],
          createdAt: DateTime.parse(json['created_at']),
          updatedAt: DateTime.parse(json['updated_at']),
        )
      ).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to load medical services',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
