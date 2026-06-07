import '../../../../core/network/dio_client.dart';
import '../models/customer_model.dart';
import '../models/customer_update_request.dart';

abstract class CustomerRemoteDataSource {
  Future<CustomerModel> getCustomerById(int id);
  Future<CustomerModel> updateCustomer(int id, CustomerUpdateRequest request);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final DioClient dioClient;

  CustomerRemoteDataSourceImpl(this.dioClient);

  @override
  Future<CustomerModel> getCustomerById(int id) async {
    try {
      final response = await dioClient.client.get('/customers/$id');
      return CustomerModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch customer: $e');
    }
  }

  @override
  Future<CustomerModel> updateCustomer(int id, CustomerUpdateRequest request) async {
    try {
      final response = await dioClient.client.put(
        '/customers/$id',
        data: request.toJson(),
      );
      return CustomerModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }
}
