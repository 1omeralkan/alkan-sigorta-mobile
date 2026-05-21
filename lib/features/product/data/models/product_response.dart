class ProductResponse {
  final int id;
  final String name;
  final String description;
  final double amount;

  ProductResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
    };
  }
}
