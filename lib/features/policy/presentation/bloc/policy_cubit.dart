import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/policy_repository.dart';
import 'policy_state.dart';

class PolicyCubit extends Cubit<PolicyState> {
  final PolicyRepository _repository;

  PolicyCubit(this._repository) : super(PolicyInitial());

  Future<void> loadPolicies(int customerId) async {
    emit(PolicyLoading());

    try {
      final policies = await _repository.getPoliciesByCustomerId(customerId);
      emit(PolicyLoaded(policies));
    } catch (e) {
      emit(PolicyFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadPolicyById(int policyId) async {
    emit(PolicyDetailLoading());

    try {
      final policy = await _repository.getPolicyById(policyId);
      emit(PolicyDetailLoaded(policy));
    } catch (e) {
      emit(PolicyDetailFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void reset() {
    emit(PolicyInitial());
  }
}
