import '../entities/doctor.dart';

abstract class DoctorRepository {
  Future<Doctor> createDoctor({
    required String fullName,
    required String login,
    required String email,
    required String password,
    required String specialization,
  });
  
  Future<Doctor> getDoctor(int id);
  Future<Doctor> updateDoctor(Doctor doctor);
  Future<List<Doctor>> getAllDoctors();
  Future<void> deleteDoctor(int id);
}