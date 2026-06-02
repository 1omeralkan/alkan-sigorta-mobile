import 'policy_coverage_model.dart';

class PolicyModel {
  final int id;
  final int customerId;
  final int? applicationId;
  final int productId;
  final String startDate;
  final String endDate;
  final double amount;
  final String currencyCode;
  final String policyStatus;
  final bool isActive;
  final List<PolicyCoverageModel> coverages;

  PolicyModel({
    required this.id,
    required this.customerId,
    this.applicationId,
    required this.productId,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.currencyCode,
    required this.policyStatus,
    required this.isActive,
    required this.coverages,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      id: json['id'] as int,
      customerId: json['customerId'] as int,
      applicationId: json['applicationId'] as int?,
      productId: json['productId'] as int,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currencyCode: json['currencyCode'] as String? ?? 'TRY',
      policyStatus: json['policyStatus'] as String? ?? 'ACTIVE',
      isActive: json['isActive'] as bool? ?? true,
      coverages: (json['coverages'] as List<dynamic>?)
              ?.map((coverage) => PolicyCoverageModel.fromJson(coverage as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'applicationId': applicationId,
      'productId': productId,
      'startDate': startDate,
      'endDate': endDate,
      'amount': amount,
      'currencyCode': currencyCode,
      'policyStatus': policyStatus,
      'isActive': isActive,
      'coverages': coverages.map((coverage) => coverage.toJson()).toList(),
    };
  }

  String get statusText {
    switch (policyStatus) {
      case 'ACTIVE':
        return 'Aktif';
      case 'CANCELLED':
        return 'İptal Edildi';
      case 'EXPIRED':
        return 'Süresi Doldu';
      default:
        return policyStatus;
    }
  }

  String get formattedAmount {
    return '${amount.toStringAsFixed(2)} $currencyCode';
  }
}
