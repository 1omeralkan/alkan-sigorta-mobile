import '../../data/models/customer_model.dart';
import '../../data/models/customer_update_request.dart';

abstract class CustomerRepository {
  Future<CustomerModel> getCustomerById(int id);
  Future<CustomerModel> updateCustomer(int id, CustomerUpdateRequest request);
}
