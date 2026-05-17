import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<bool> login(String email, String password) async {
    try {
      final result = await _remoteDataSource.login(email, password);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
