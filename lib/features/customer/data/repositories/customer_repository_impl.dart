import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';
import '../models/customer_model.dart';
import '../models/customer_update_request.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl(this.remoteDataSource);

  @override
  Future<CustomerModel> getCustomerById(int id) {
    return remoteDataSource.getCustomerById(id);
  }

  @override
  Future<CustomerModel> updateCustomer(int id, CustomerUpdateRequest request) {
    return remoteDataSource.updateCustomer(id, request);
  }
}
