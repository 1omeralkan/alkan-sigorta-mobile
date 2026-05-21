import '../../data/models/product_response.dart';

abstract class ProductRepository {
  Future<List<ProductResponse>> getProducts();
}
