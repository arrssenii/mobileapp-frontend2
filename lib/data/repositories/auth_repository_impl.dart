import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login(String phone, String password) async {
    final userModel = await remoteDataSource.login(phone, password);
    return userModel; // UserModel наследуется от User, поэтому преобразование не нужно
  }
}