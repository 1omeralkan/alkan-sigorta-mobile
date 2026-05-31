import '../../domain/repositories/collection_repository.dart';
import '../datasources/collection_remote_data_source.dart';
import '../models/collection_response.dart';
import '../models/payment_request.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionRemoteDataSource _remoteDataSource;

  CollectionRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CollectionResponse>> getCollectionsByCustomerId(int customerId) async {
    try {
      return await _remoteDataSource.getCollectionsByCustomerId(customerId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CollectionResponse>> getCollectionsByApplicationId(int applicationId) async {
    try {
      return await _remoteDataSource.getCollectionsByApplicationId(applicationId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CollectionResponse> payInstallment(int collectionId, PaymentRequest paymentRequest) async {
    try {
      return await _remoteDataSource.payInstallment(collectionId, paymentRequest);
    } catch (e) {
      rethrow;
    }
  }
}
