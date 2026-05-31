import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/customer_save_request.dart';
import '../models/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(String email, String password);
  Future<void> register(CustomerSaveRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _dioClient.client.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponse.fromJson(response.data);
      }

      throw Exception('Giriş başarısız oldu');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Email veya şifre hatalı');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Geçersiz istek');
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

  @override
  Future<void> register(CustomerSaveRequest request) async {
    try {
      final response = await _dioClient.client.post(
        '/auth/register',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Kayıt işlemi başarısız oldu');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? 'Geçersiz bilgiler';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 409) {
        throw Exception('Bu email veya TC No ile kayıtlı kullanıcı mevcut');
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
