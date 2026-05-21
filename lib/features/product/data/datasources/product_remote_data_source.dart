import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_response.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductResponse>> getProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient _dioClient;

  ProductRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProductResponse>> getProducts() async {
    try {
      final response = await _dioClient.client.get('http://10.0.2.2:8082/api/v1/products');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => ProductResponse.fromJson(json)).toList();
      } else {
        throw Exception('Ürünler yüklenirken hata oluştu: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Geçersiz istek: ${e.response?.data}');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Sunucu hatası: ${e.response?.data}');
      } else {
        throw Exception('Ürünler yüklenirken hata oluştu: ${e.message}');
      }
    } catch (e) {
      throw Exception('Beklenmeyen hata: $e');
    }
  }
}
