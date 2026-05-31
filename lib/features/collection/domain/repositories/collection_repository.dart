import '../../data/models/collection_response.dart';
import '../../data/models/payment_request.dart';

abstract class CollectionRepository {
  Future<List<CollectionResponse>> getCollectionsByCustomerId(int customerId);
  Future<List<CollectionResponse>> getCollectionsByApplicationId(int applicationId);
  Future<CollectionResponse> payInstallment(int collectionId, PaymentRequest paymentRequest);
}
