import '../repositories/doctor_repository.dart';
import '../entities/doctor.dart';

class GetDoctor {
  final DoctorRepository repository;

  GetDoctor(this.repository);

  Future<Doctor> call(int id) async {
    return await repository.getDoctor(id);
  }
}
