import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    await Future.delayed(const Duration(seconds: 2));

    if (email == 'test@alkan.com' && password == '123456') {
      emit(const AuthSuccess());
    } else {
      emit(const AuthFailure('E-posta veya şifre hatalı.'));
    }
  }
}
