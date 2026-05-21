import '../../data/models/product_response.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductResponse> products;

  ProductLoaded(this.products);
}

class ProductFailure extends ProductState {
  final String message;

  ProductFailure(this.message);
}
