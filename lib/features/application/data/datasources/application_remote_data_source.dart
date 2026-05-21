import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/application_save_request.dart';

abstract class ApplicationRemoteDataSource {
  Future<void> createApplication(ApplicationSaveRequest request);
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
}
