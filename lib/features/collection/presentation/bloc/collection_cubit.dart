import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/payment_request.dart';
import '../../domain/repositories/collection_repository.dart';
import 'collection_state.dart';

class CollectionCubit extends Cubit<CollectionState> {
  final CollectionRepository _repository;

  CollectionCubit(this._repository) : super(const CollectionInitial());

  Future<void> loadCollections(int customerId) async {
    emit(const CollectionLoading());

    try {
      final collections = await _repository.getCollectionsByCustomerId(customerId);
      emit(CollectionLoaded(collections));
    } catch (e) {
      emit(CollectionFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadCollectionsByApplicationId(int applicationId) async {
    emit(const CollectionLoading());

    try {
      final collections = await _repository.getCollectionsByApplicationId(applicationId);
      emit(CollectionLoaded(collections));
    } catch (e) {
      emit(CollectionFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> payInstallment(int collectionId, PaymentRequest paymentRequest, int customerId) async {
    emit(const PaymentProcessing());

    try {
      await _repository.payInstallment(collectionId, paymentRequest);
      emit(const PaymentSuccess());

      // Ödeme başarılı olduktan sonra listeyi yenile
      await loadCollections(customerId);
    } catch (e) {
      // Hata durumunda listeyi yenilemeyelim, dialog açık kalsın
      emit(PaymentFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
