import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/policy_repository.dart';
import '../../../product/domain/repositories/product_repository.dart';
import 'policy_state.dart';

class PolicyCubit extends Cubit<PolicyState> {
  final PolicyRepository _policyRepository;
  final ProductRepository _productRepository;
  final Map<int, String> _productCache = {}; // Product ID -> Name mapping

  PolicyCubit(this._policyRepository, this._productRepository) : super(PolicyInitial());

  Future<void> loadPolicies(int customerId) async {
    emit(PolicyLoading());

    try {
      final policies = await _policyRepository.getPoliciesByCustomerId(customerId);

      // Load product names for all unique product IDs
      await _loadProductNames(policies.map((p) => p.productId).toSet().toList());

      emit(PolicyLoaded(policies));
    } catch (e) {
      emit(PolicyFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _loadProductNames(List<int> productIds) async {
    try {
      for (final productId in productIds) {
        if (!_productCache.containsKey(productId)) {
          try {
            final product = await _productRepository.getProductById(productId);
            _productCache[productId] = product.name;
          } catch (e) {
            // If product fetch fails, use fallback
            _productCache[productId] = 'Ürün #$productId';
          }
        }
      }
    } catch (e) {
      // Silently fail - policy list will still show with IDs
    }
  }

  String getProductName(int productId) {
    return _productCache[productId] ?? 'Ürün #$productId';
  }

  Future<void> loadPolicyById(int policyId) async {
    emit(PolicyDetailLoading());

    try {
      final policy = await _policyRepository.getPolicyById(policyId);
      emit(PolicyDetailLoaded(policy));
    } catch (e) {
      emit(PolicyDetailFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void reset() {
    emit(PolicyInitial());
  }
}
