import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(const AuthInitial());

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    try {
      final result = await authRepository.login(email, password);

      if (result) {
        emit(const AuthSuccess());
      } else {
        emit(const AuthFailure('Giriş başarısız oldu.'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
