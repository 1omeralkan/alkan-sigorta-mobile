import '../../data/models/customer_save_request.dart';
import '../../data/models/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String email, String password);
  Future<void> register(CustomerSaveRequest request);
}
