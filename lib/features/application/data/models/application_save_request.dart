class ApplicationSaveRequest {
  final int customerId;
  final int productId;
  final String? description;
  final String paymentTypeCode;
  final int installmentCount;
  final List<String> requestedCoverageCodes;
  final int? age;
  final double? height;
  final double? weight;
  final String? gender;

  ApplicationSaveRequest({
    required this.customerId,
    required this.productId,
    this.description,
    required this.paymentTypeCode,
    required this.installmentCount,
    required this.requestedCoverageCodes,
    this.age,
    this.height,
    this.weight,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'productId': productId,
      'description': description,
      'paymentTypeCode': paymentTypeCode,
      'installmentCount': installmentCount,
      'requestedCoverageCodes': requestedCoverageCodes,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
    };
  }
}
