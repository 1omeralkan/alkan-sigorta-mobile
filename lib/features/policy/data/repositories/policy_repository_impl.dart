import '../../domain/repositories/policy_repository.dart';
import '../datasources/policy_remote_data_source.dart';
import '../models/policy_model.dart';

class PolicyRepositoryImpl implements PolicyRepository {
  final PolicyRemoteDataSource _remoteDataSource;

  PolicyRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<PolicyModel>> getPoliciesByCustomerId(int customerId) async {
    try {
      return await _remoteDataSource.getPoliciesByCustomerId(customerId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PolicyModel> getPolicyById(int policyId) async {
    try {
      return await _remoteDataSource.getPolicyById(policyId);
    } catch (e) {
      rethrow;
    }
  }
}
