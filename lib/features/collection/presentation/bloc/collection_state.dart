import 'package:equatable/equatable.dart';
import '../../data/models/collection_response.dart';

abstract class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object?> get props => [];
}

class CollectionInitial extends CollectionState {
  const CollectionInitial();
}

class CollectionLoading extends CollectionState {
  const CollectionLoading();
}

class CollectionLoaded extends CollectionState {
  final List<CollectionResponse> collections;

  const CollectionLoaded(this.collections);

  @override
  List<Object?> get props => [collections];
}

class CollectionFailure extends CollectionState {
  final String message;

  const CollectionFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentProcessing extends CollectionState {
  const PaymentProcessing();
}

class PaymentSuccess extends CollectionState {
  const PaymentSuccess();
}

class PaymentFailure extends CollectionState {
  final String message;

  const PaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}
