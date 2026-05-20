import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/country_model.dart';
import '../models/city_model.dart';

abstract class ParameterRemoteDataSource {
  Future<List<CountryModel>> getCountries();
  Future<List<CityModel>> getCities(int countryId);
}

class ParameterRemoteDataSourceImpl implements ParameterRemoteDataSource {
  final DioClient _dioClient;

  // Parameter Microservice base URL (8081 port)
  static const String _parameterServiceBaseUrl = 'http://10.0.2.2:8081/api/v1';

  ParameterRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await _dioClient.client.get('$_parameterServiceBaseUrl/countries');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => CountryModel.fromJson(json)).toList();
      }

      throw Exception('Ülke listesi alınamadı');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Bağlantı zaman aşımına uğradı');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('İnternet bağlantınızı kontrol edin');
      }
      throw Exception('Ülke listesi yüklenirken hata oluştu');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }

  @override
  Future<List<CityModel>> getCities(int countryId) async {
    try {
      final response = await _dioClient.client.get('$_parameterServiceBaseUrl/cities/country/$countryId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => CityModel.fromJson(json)).toList();
      }

      throw Exception('Şehir listesi alınamadı');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Bağlantı zaman aşımına uğradı');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('İnternet bağlantınızı kontrol edin');
      }
      throw Exception('Şehir listesi yüklenirken hata oluştu');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu');
    }
  }
}
