class PolicyCoverageModel {
  final int id;
  final String coverageCode;
  final String name;
  final double amount;

  PolicyCoverageModel({
    required this.id,
    required this.coverageCode,
    required this.name,
    required this.amount,
  });

  factory PolicyCoverageModel.fromJson(Map<String, dynamic> json) {
    return PolicyCoverageModel(
      id: json['id'] as int,
      coverageCode: json['coverageCode'] as String? ?? '',
      name: json['name'] as String? ?? 'Bilinmeyen Teminat',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coverageCode': coverageCode,
      'name': name,
      'amount': amount,
    };
  }
}
