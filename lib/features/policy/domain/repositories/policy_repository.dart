import '../../data/models/policy_model.dart';

abstract class PolicyRepository {
  Future<List<PolicyModel>> getPoliciesByCustomerId(int customerId);
  Future<PolicyModel> getPolicyById(int policyId);
}
