class CollectionResponse {
  final int id;
  final int applicationId;
  final int? policyId;
  final int installmentNumber;
  final double installmentAmount;
  final String dueDate;
  final bool isPaid;
  final bool isActive;

  CollectionResponse({
    required this.id,
    required this.applicationId,
    this.policyId,
    required this.installmentNumber,
    required this.installmentAmount,
    required this.dueDate,
    required this.isPaid,
    required this.isActive,
  });

  factory CollectionResponse.fromJson(Map<String, dynamic> json) {
    return CollectionResponse(
      id: json['id'] as int,
      applicationId: json['applicationId'] as int,
      policyId: json['policyId'] as int?,
      installmentNumber: json['installmentNumber'] as int,
      installmentAmount: (json['installmentAmount'] as num).toDouble(),
      dueDate: json['dueDate'] as String,
      isPaid: json['isPaid'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
