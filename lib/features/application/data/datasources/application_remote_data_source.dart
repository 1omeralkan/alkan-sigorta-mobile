import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/application_save_request.dart';
import '../models/application_response.dart';

abstract class ApplicationRemoteDataSource {
  Future<void> createApplication(ApplicationSaveRequest request);
  Future<List<ApplicationResponse>> getApplicationsByCustomerId(int customerId);
  Future<void> cancelApplication(int applicationId);
}

class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  final DioClient _dioClient;

  ApplicationRemoteDataSourceImpl(this._dioClient);

  @override
  Future<void> createApplication(ApplicationSaveRequest request) async {
    try {
      final response = await _dioClient.client.post(
        'http://10.0.2.2:8083/api/v1/applications',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Başvuru oluşturma işlemi başarısız oldu');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? 'Geçersiz başvuru bilgileri';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 500) {
        throw Exception('Sunucu hatası oluştu');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Bağlantı zaman aşımına uğradı');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('İnternet bağlantınızı kontrol edin');
      }
      throw Exception('Bir hata oluştu: ${e.message}');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }

  @override
  Future<List<ApplicationResponse>> getApplicationsByCustomerId(int customerId) async {
    try {
      final response = await _dioClient.client.get(
        'http://10.0.2.2:8083/api/v1/applications/customer/$customerId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => ApplicationResponse.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Başvurular yüklenemedi');
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
      throw Exception('Bir hata oluştu: ${e.message}');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }

  @override
  Future<void> cancelApplication(int applicationId) async {
    try {
      final response = await _dioClient.client.patch(
        'http://10.0.2.2:8083/api/v1/applications/$applicationId/status',
        queryParameters: {'status': 'CANCELLED'},
      );

      if (response.statusCode != 200) {
        throw Exception('Başvuru iptal işlemi başarısız oldu');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? 'Geçersiz işlem';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 404) {
        throw Exception('Başvuru bulunamadı');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Sunucu hatası oluştu');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Bağlantı zaman aşımına uğradı');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('İnternet bağlantınızı kontrol edin');
      }
      throw Exception('Bir hata oluştu: ${e.message}');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }
}
