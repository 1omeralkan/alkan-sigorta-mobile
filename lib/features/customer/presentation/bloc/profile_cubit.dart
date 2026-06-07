import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/models/customer_update_request.dart';
import '../../domain/repositories/customer_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final CustomerRepository customerRepository;

  ProfileCubit(this.customerRepository) : super(ProfileInitial());

  Future<void> loadProfile(int customerId) async {
    emit(ProfileLoading());
    try {
      final customer = await customerRepository.getCustomerById(customerId);
      emit(ProfileLoaded(customer));
    } catch (e) {
      emit(ProfileError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> updateProfile(int customerId, CustomerUpdateRequest request) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentState.customer));
    }

    try {
      final updatedCustomer = await customerRepository.updateCustomer(customerId, request);
      emit(ProfileUpdateSuccess(updatedCustomer));
      await Future.delayed(const Duration(milliseconds: 500));
      emit(ProfileLoaded(updatedCustomer));
    } catch (e) {
      emit(ProfileError(ErrorHandler.getErrorMessage(e)));
      if (currentState is ProfileLoaded) {
        await Future.delayed(const Duration(seconds: 2));
        emit(ProfileLoaded(currentState.customer));
      }
    }
  }
}
