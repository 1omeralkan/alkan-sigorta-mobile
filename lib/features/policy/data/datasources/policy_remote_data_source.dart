import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/policy_model.dart';

abstract class PolicyRemoteDataSource {
  Future<List<PolicyModel>> getPoliciesByCustomerId(int customerId);
  Future<PolicyModel> getPolicyById(int policyId);
}

class PolicyRemoteDataSourceImpl implements PolicyRemoteDataSource {
  final DioClient _dioClient;

  PolicyRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PolicyModel>> getPoliciesByCustomerId(int customerId) async {
    try {
      final response = await _dioClient.client.get(
        'http://10.0.2.2:8085/api/v1/policies/customer/$customerId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => PolicyModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Poliçeler yüklenemedi');
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
  Future<PolicyModel> getPolicyById(int policyId) async {
    try {
      final response = await _dioClient.client.get(
        'http://10.0.2.2:8085/api/v1/policies/$policyId',
      );

      if (response.statusCode == 200) {
        return PolicyModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Poliçe yüklenemedi');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Poliçe bulunamadı');
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
