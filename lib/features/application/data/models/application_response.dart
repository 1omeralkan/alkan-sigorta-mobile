class ApplicationResponse {
  final int id;
  final String applicationNumber;
  final int customerId;
  final String? customerName;
  final int productId;
  final String productName;
  final int? productAmountId;
  final double amount;
  final String applicationDate;
  final String status;
  final String? description;
  final bool isActive;
  final String? paymentTypeCode;
  final String? paymentTypeName;
  final int? installmentCount;
  final double? installmentAmount;

  ApplicationResponse({
    required this.id,
    required this.applicationNumber,
    required this.customerId,
    this.customerName,
    required this.productId,
    required this.productName,
    this.productAmountId,
    required this.amount,
    required this.applicationDate,
    required this.status,
    this.description,
    required this.isActive,
    this.paymentTypeCode,
    this.paymentTypeName,
    this.installmentCount,
    this.installmentAmount,
  });

  factory ApplicationResponse.fromJson(Map<String, dynamic> json) {
    return ApplicationResponse(
      id: json['id'] as int,
      applicationNumber: json['applicationNumber'] as String,
      customerId: json['customerId'] as int,
      customerName: json['customerName'] as String?,
      productId: json['productId'] as int,
      productName: json['productName'] as String? ?? 'Bilinmeyen Ürün',
      productAmountId: json['productAmountId'] as int?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      applicationDate: json['applicationDate'] as String,
      status: json['status'] as String? ?? 'PENDING',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      paymentTypeCode: json['paymentTypeCode'] as String?,
      paymentTypeName: json['paymentTypeName'] as String?,
      installmentCount: json['installmentCount'] as int?,
      installmentAmount: (json['installmentAmount'] as num?)?.toDouble(),
    );
  }
}
