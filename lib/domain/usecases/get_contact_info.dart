import '../repositories/contact_info_repository.dart';
import '../entities/contact_info.dart';

class GetContactInfo {
  final ContactInfoRepository repository;

  GetContactInfo(this.repository);

  Future<ContactInfo> call(int patientId) async {
    return await repository.getContactInfo(patientId);
  }
}