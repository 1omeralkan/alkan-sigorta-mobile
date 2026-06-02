import '../../data/models/policy_model.dart';

abstract class PolicyState {}

class PolicyInitial extends PolicyState {}

class PolicyLoading extends PolicyState {}

class PolicyLoaded extends PolicyState {
  final List<PolicyModel> policies;

  PolicyLoaded(this.policies);
}

class PolicyFailure extends PolicyState {
  final String message;

  PolicyFailure(this.message);
}

class PolicyDetailLoading extends PolicyState {}

class PolicyDetailLoaded extends PolicyState {
  final PolicyModel policy;

  PolicyDetailLoaded(this.policy);
}

class PolicyDetailFailure extends PolicyState {
  final String message;

  PolicyDetailFailure(this.message);
}
