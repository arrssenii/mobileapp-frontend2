import '../entities/reception.dart';

abstract class ReceptionRepository {
  Future<Reception> createReception(Reception reception);
  Future<List<Reception>> getDoctorReceptions(int doctorId);
  Future<Reception> updateReceptionStatus(int receptionId, String status);
}
