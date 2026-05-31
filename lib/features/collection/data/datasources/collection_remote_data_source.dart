import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/collection_response.dart';
import '../models/payment_request.dart';

abstract class CollectionRemoteDataSource {
  Future<List<CollectionResponse>> getCollectionsByCustomerId(int customerId);
  Future<List<CollectionResponse>> getCollectionsByApplicationId(int applicationId);
  Future<CollectionResponse> payInstallment(int collectionId, PaymentRequest paymentRequest);
}

class CollectionRemoteDataSourceImpl implements CollectionRemoteDataSource {
  final DioClient _dioClient;

  CollectionRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<CollectionResponse>> getCollectionsByCustomerId(int customerId) async {
    try {
      final response = await _dioClient.client.get(
        'http://10.0.2.2:8084/api/v1/collections/customer/$customerId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => CollectionResponse.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Tahsilatlar yüklenemedi');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      } else if (e.response?.statusCode == 500) {
        throw Exception('Sunucu hatası oluştu');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Bağlantı zaman aşımına uğradı');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('İnternet bağlantınızı kontrol edin');
      }
      throw Exception('Bir hata oluştu. Lütfen tekrar deneyin');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }

  @override
  Future<List<CollectionResponse>> getCollectionsByApplicationId(int applicationId) async {
    try {
      final response = await _dioClient.client.get(
        'http://10.0.2.2:8084/api/v1/collections/application/$applicationId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => CollectionResponse.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Tahsilatlar yüklenemedi');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      } else if (e.response?.statusCode == 500) {
        throw Exception('Sunucu hatası oluştu');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Bağlantı zaman aşımına uğradı');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('İnternet bağlantınızı kontrol edin');
      }
      throw Exception('Bir hata oluştu. Lütfen tekrar deneyin');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }

  @override
  Future<CollectionResponse> payInstallment(int collectionId, PaymentRequest paymentRequest) async {
    try {
      final response = await _dioClient.client.patch(
        'http://10.0.2.2:8084/api/v1/collections/$collectionId/pay',
        data: paymentRequest.toJson(),
      );

      if (response.statusCode == 200) {
        return CollectionResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Ödeme işlemi başarısız oldu');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? 'Geçersiz ödeme bilgileri';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 404) {
        throw Exception('Taksit bulunamadı');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Bağlantı zaman aşımına uğradı');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('İnternet bağlantınızı kontrol edin');
      }
      throw Exception('Bir hata oluştu. Lütfen tekrar deneyin');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }
}
