import '../repositories/contact_info_repository.dart';
import '../entities/contact_info.dart';

class CreateContactInfo {
  final ContactInfoRepository repository;

  CreateContactInfo(this.repository);

  Future<ContactInfo> call({
    required int patientId,
    required String phone,
    required String email,
    required String address,
  }) async {
    return await repository.createContactInfo(
      patientId: patientId,
      phone: phone,
      email: email,
      address: address,
    );
  }
}
