import '../../domain/repositories/contact_info_repository.dart';
import '../../domain/entities/contact_info.dart';
import '../datasources/contact_info_remote_data_source.dart';
import '../models/contact_info/create_contact_info_request_dto.dart';
import '../../core/error/exceptions.dart';

class ContactInfoRepositoryImpl implements ContactInfoRepository {
  final ContactInfoRemoteDataSource remoteDataSource;

  ContactInfoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ContactInfo> createContactInfo({
    required int patientId,
    required String phone,
    required String email,
    required String address,
  }) async {
    try {
      return await remoteDataSource.createContactInfo(
        CreateContactInfoRequestDTO(
          patient_id: patientId,
          phone: phone,
          email: email,
          address: address,
        ),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create contact info',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ContactInfo> getContactInfo(int patientId) async {
    try {
      return await remoteDataSource.getContactInfo(patientId);
    } catch (e) {
      throw ServerException(
        message: 'Failed to get contact info',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ContactInfo> updateContactInfo(ContactInfo contactInfo) {
    // TODO: реализовать обновление
    throw UnimplementedError();
  }

  @override
  Future<void> deleteContactInfo(int contactInfoId) {
    // TODO: реализовать удаление
    throw UnimplementedError();
  }
}
