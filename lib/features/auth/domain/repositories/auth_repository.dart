import '../../data/models/customer_save_request.dart';

abstract class AuthRepository {
  Future<String> login(String email, String password);
  Future<void> register(CustomerSaveRequest request);
}
