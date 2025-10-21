import 'package:dio/dio.dart';
import '../../domain/entities/doctor.dart';
import '../models/doctor/create_doctor_request_dto.dart';
import '../models/doctor/doctor_response_dto.dart';
import '../../core/error/exceptions.dart';

abstract class DoctorRemoteDataSource {
  Future<Doctor> createDoctor(CreateDoctorRequestDTO request);
  Future<Doctor> getDoctor(int id);
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final Dio dio;

  DoctorRemoteDataSourceImpl({required this.dio});

  @override
  Future<Doctor> createDoctor(CreateDoctorRequestDTO request) async {
    try {
      final response = await dio.post(
        '/doctors',
        data: request.toJson(),
      );
      
      final dto = DoctorResponseDTO.fromJson(response.data);
      return dto.toEntity(
        createdAt: DateTime.parse(response.data['created_at']),
        updatedAt: DateTime.parse(response.data['updated_at']),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to create doctor',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Doctor> getDoctor(int id) async {
    try {
      final response = await dio.get('/doctors/$id');
      final dto = DoctorResponseDTO.fromJson(response.data);
      
      return dto.toEntity(
        createdAt: DateTime.parse(response.data['created_at']),
        updatedAt: DateTime.parse(response.data['updated_at']),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to get doctor',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
