import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_response.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ProductResponse>> getProducts() async {
    return await _remoteDataSource.getProducts();
  }

  @override
  Future<ProductResponse> getProductById(int id) async {
    return await _remoteDataSource.getProductById(id);
  }
}
