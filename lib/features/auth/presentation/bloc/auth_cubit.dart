import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final StorageService storageService;

  AuthCubit(this.authRepository, this.storageService)
      : super(const AuthInitial());

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    try {
      final response = await authRepository.login(email, password);

      await storageService.saveToken(response.token);
      await storageService.saveCustomerId(response.customerId);
      await storageService.saveCustomerName('${response.ad} ${response.soyad}');

      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
