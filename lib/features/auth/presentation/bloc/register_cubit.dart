import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/customer_save_request.dart';
import '../../domain/repositories/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterCubit(this._authRepository) : super(const RegisterInitial());

  Future<void> register(CustomerSaveRequest request) async {
    emit(const RegisterLoading());

    try {
      await _authRepository.register(request);
      emit(const RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
