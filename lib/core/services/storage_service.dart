import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;

  StorageService()
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  static const String _tokenKey = 'auth_token';
  static const String _customerIdKey = 'customer_id';
  static const String _customerNameKey = 'customer_name';

  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw Exception('Token kaydedilemedi: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      throw Exception('Token okunamadı: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw Exception('Token silinemedi: $e');
    }
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveCustomerId(int customerId) async {
    try {
      await _secureStorage.write(key: _customerIdKey, value: customerId.toString());
    } catch (e) {
      throw Exception('Customer ID kaydedilemedi: $e');
    }
  }

  Future<int?> getCustomerId() async {
    try {
      final value = await _secureStorage.read(key: _customerIdKey);
      return value != null ? int.tryParse(value) : null;
    } catch (e) {
      throw Exception('Customer ID okunamadı: $e');
    }
  }

  Future<void> deleteCustomerId() async {
    try {
      await _secureStorage.delete(key: _customerIdKey);
    } catch (e) {
      throw Exception('Customer ID silinemedi: $e');
    }
  }

  Future<void> saveCustomerName(String name) async {
    try {
      await _secureStorage.write(key: _customerNameKey, value: name);
    } catch (e) {
      throw Exception('Customer name kaydedilemedi: $e');
    }
  }

  Future<String?> getCustomerName() async {
    try {
      return await _secureStorage.read(key: _customerNameKey);
    } catch (e) {
      throw Exception('Customer name okunamadı: $e');
    }
  }

  Future<void> deleteCustomerName() async {
    try {
      await _secureStorage.delete(key: _customerNameKey);
    } catch (e) {
      throw Exception('Customer name silinemedi: $e');
    }
  }
}
