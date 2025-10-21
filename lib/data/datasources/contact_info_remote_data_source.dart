import 'package:dio/dio.dart';
import '../../domain/entities/contact_info.dart';
import '../models/contact_info/create_contact_info_request_dto.dart';
import '../models/contact_info/contact_info_response_dto.dart';
import '../../core/error/exceptions.dart';

abstract class ContactInfoRemoteDataSource {
  Future<ContactInfo> createContactInfo(
      CreateContactInfoRequestDTO request);
  Future<ContactInfo> getContactInfo(int patientId);
}

class ContactInfoRemoteDataSourceImpl
    implements ContactInfoRemoteDataSource {
  final Dio dio;

  ContactInfoRemoteDataSourceImpl({required this.dio});

  @override
  Future<ContactInfo> createContactInfo(
      CreateContactInfoRequestDTO request) async {
    try {
      final response = await dio.post(
        '/contact-infos',
        data: request.toJson(),
      );
      
      // В реальном API ответ будет содержать полные данные
      return ContactInfo(
        id: response.data['id'],
        patientId: request.patient_id,
        phone: request.phone,
        email: request.email,
        address: request.address,
        createdAt: DateTime.parse(response.data['created_at']),
        updatedAt: DateTime.parse(response.data['updated_at']),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to create contact info',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ContactInfo> getContactInfo(int patientId) async {
    try {
      final response = await dio.get('/patients/$patientId/contact-info');
      final dto = ContactInfoResponseDTO.fromJson(response.data);
      
      return dto.toEntity(
        id: response.data['id'],
        patientId: patientId,
        createdAt: DateTime.parse(response.data['created_at']),
        updatedAt: DateTime.parse(response.data['updated_at']),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to get contact info',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
