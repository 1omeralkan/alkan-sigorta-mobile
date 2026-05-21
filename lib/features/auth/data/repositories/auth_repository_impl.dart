import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/customer_save_request.dart';
import '../models/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _remoteDataSource.login(email, password);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> register(CustomerSaveRequest request) async {
    try {
      await _remoteDataSource.register(request);
    } catch (e) {
      rethrow;
    }
  }
}
