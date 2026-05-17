import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await _dioClient.client.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        if (token == null || token.isEmpty) {
          throw Exception('Token alınamadı');
        }
        return token;
      }

      throw Exception('Giriş başarısız oldu');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Email veya şifre hatalı');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Geçersiz istek');
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
