import '../entities/contact_info.dart';

abstract class ContactInfoRepository {
  Future<ContactInfo> createContactInfo({
    required int patientId,
    required String phone,
    required String email,
    required String address,
  });
  
  Future<ContactInfo> getContactInfo(int patientId);
  Future<ContactInfo> updateContactInfo(ContactInfo contactInfo);
  Future<void> deleteContactInfo(int contactInfoId);
}